defmodule AlgoliaElixir.Middleware.BaseUrlWithRetry do
  @moduledoc false

  alias Tesla.Middleware.BaseUrl

  @behaviour Tesla.Middleware

  @defaults [
    delay: 50,
    max_retries: 5,
    max_delay: 5_000,
    jitter_factor: 0.2
  ]

  @impl Tesla.Middleware
  def call(env, next, opts) do
    opts = opts || []

    context = %{
      app_id: opts[:app_id],
      retries: 0,
      delay: integer_opt!(opts, :delay, 1),
      max_retries: integer_opt!(opts, :max_retries, 0),
      max_delay: integer_opt!(opts, :max_delay, 1),
      should_retry: Keyword.get(opts, :should_retry, &match?({:error, _}, &1)),
      jitter_factor: float_opt!(opts, :jitter_factor, 0, 1)
    }

    retry(env, next, context)
  end

  defp run_with_base_url(%{opts: [action: :write]} = env, next, %{app_id: app_id}) do
    BaseUrl.call(env, next, "https://#{app_id}.algolia.net/1")
  end

  defp run_with_base_url(env, next, %{retries: 0, app_id: app_id}) do
    BaseUrl.call(env, next, "https://#{app_id}-dsn.algolia.net/1")
  end

  defp run_with_base_url(env, next, %{retries: retries, app_id: app_id}) do
    n = rem(retries, 3) + 1

    BaseUrl.call(env, next, "https://#{app_id}-#{n}.algolia.net/1")
  end

  # If we have max retries set to 0 don't retry
  defp retry(env, next, %{max_retries: 0} = context), do: run_with_base_url(env, next, context)

  # If we're on our last retry then just run and don't handle the error
  defp retry(env, next, %{max_retries: max, retries: max} = context) do
    run_with_base_url(env, next, context)
  end

  # Otherwise we retry if we get a retriable error
  defp retry(env, next, context) do
    res = run_with_base_url(env, next, context)

    if context.should_retry.(res) do
      backoff(context.max_delay, context.delay, context.retries, context.jitter_factor)
      context = update_in(context, [:retries], &(&1 + 1))
      retry(env, next, context)
    else
      res
    end
  end

  # Exponential backoff with jitter
  defp backoff(cap, base, attempt, jitter_factor) do
    factor = Bitwise.bsl(1, attempt)
    max_sleep = min(cap, base * factor)

    # This ensures that the delay's order of magnitude is kept intact, while still having some jitter.
    # Generates a value x where 1-jitter_factor <= x <= 1 + jitter_factor
    jitter = 1 + 2 * jitter_factor * :rand.uniform() - jitter_factor

    # The actual delay is in the range max_sleep * (1 - jitter_factor), max_sleep * (1 + jitter_factor)
    delay = trunc(max_sleep + jitter)

    :timer.sleep(delay)
  end

  defp integer_opt!(opts, key, min) do
    case Keyword.fetch(opts, key) do
      {:ok, value} when is_integer(value) and value >= min -> value
      {:ok, invalid} -> invalid_integer(key, invalid, min)
      :error -> @defaults[key]
    end
  end

  defp float_opt!(opts, key, min, max) do
    case Keyword.fetch(opts, key) do
      {:ok, value} when is_float(value) and value >= min and value <= max -> value
      {:ok, invalid} -> invalid_float(key, invalid, min, max)
      :error -> @defaults[key]
    end
  end

  defp invalid_integer(key, value, min) do
    raise(ArgumentError, "expected :#{key} to be an integer >= #{min}, got #{inspect(value)}")
  end

  defp invalid_float(key, value, min, max) do
    raise(
      ArgumentError,
      "expected :#{key} to be a float >= #{min} and <= #{max}, got #{inspect(value)}"
    )
  end
end
