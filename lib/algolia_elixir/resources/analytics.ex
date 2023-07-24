defmodule AlgoliaElixir.Resources.Analytics do
  use AlgoliaElixir.Client, subdomain: "analytics"

  def top_searches(index, params \\ %{}) do
    query = Map.put(params, :index, index)

    get("/searches", query: query)
  end
end
