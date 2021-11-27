defmodule AlgoliaElixir.Resources.Search do
  use AlgoliaElixir.Client

  def search(index, params), do: multi_search([%{indexName: index, params: params}])

  def multi_search(queries) do
    requests = format_multi_queries(queries)

    post("/indexes/*/queries", %{requests: requests})
  end

  defp format_multi_queries(queries) do
    Enum.map(queries, fn query ->
      params = URI.encode_query(query[:params])

      Map.put(query, :params, params)
    end)
  end
end
