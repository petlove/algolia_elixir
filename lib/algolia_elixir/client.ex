defmodule AlgoliaElixir.Client do
  defmacro __using__(opts) do
    quote location: :keep, bind_quoted: [opts: opts] do
      use Tesla

      @subdomain Keyword.get(opts, :subdomain, nil)

      plug(Tesla.Middleware.Headers, [
        {"X-Algolia-Application-Id", app_id()},
        {"X-Algolia-API-Key", api_key()}
      ])

      plug(Tesla.Middleware.Telemetry)

      plug(Tesla.Middleware.JSON, json_opts())

      plug(Elixir.AlgoliaElixir.Middleware.BaseUrlWithRetry,
        subdomain: subdomain(),
        max_retries: 3,
        should_retry: fn
          {:ok, %{status: status}} when status >= 500 -> true
          {:ok, _} -> false
          {:error, _} -> true
        end
      )

      defp app_id do
        Application.get_env(:algolia_elixir, :app_id)
      end

      defp api_key do
        Application.get_env(:algolia_elixir, :api_key)
      end

      defp json_opts do
        Application.get_env(:algolia_elixir, :json_opts)
      end

      defp subdomain, do: @subdomain || app_id()

      defmodule AlgoliaElixir.Error do
        defexception message: "Unknown error"
      end
    end
  end
end
