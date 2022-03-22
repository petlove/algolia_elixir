defmodule AlgoliaElixir.Client do
  defmacro __using__(_opts) do
    quote do
      use Tesla

      plug(Tesla.Middleware.Headers, [
        {"X-Algolia-Application-Id", app_id()},
        {"X-Algolia-API-Key", api_key()}
      ])

      plug(Tesla.Middleware.Telemetry)

      plug(Tesla.Middleware.JSON)

      plug(Elixir.AlgoliaElixir.Middleware.BaseUrlWithRetry,
        app_id: app_id(),
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

      defmodule AlgoliaElixir.Error do
        defexception message: "Unknown error"
      end
    end
  end
end
