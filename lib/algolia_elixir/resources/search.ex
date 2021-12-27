defmodule AlgoliaElixir.Resources.Search do
  use AlgoliaElixir.Client

  def search(index, params), do: multi_search([%{indexName: index, params: params}])

  def multi_search(queries) do
    requests = format_multi_queries(queries)

    post("/indexes/*/queries", %{requests: requests})
  end

  defp format_multi_queries(queries) do
    Enum.map(queries, fn %{params: params} = query ->
      formated_params = format_params(params)

      Map.put(query, :params, formated_params)
    end)
  end

  defp format_params(%{filters: filters} = params) do
    formated_filters = format_filters(filters)

    params
    |> Map.put(:filters, formated_filters)
    |> URI.encode_query()
  end

  defp format_filters(filters) when is_binary(filters), do: filters

  defp format_filters(filters) when is_map(filters) do
    filters
    |> Enum.reduce([], fn {name, values}, acc ->
      facet =
        cond do
          is_binary(values) ->
            "#{name}:#{values}"

          is_list(values) ->
            Enum.map_join(values, " OR ", fn value ->
              "#{name}:#{value}"
            end)
        end

      acc ++ ["(#{facet})"]
    end)
    |> Enum.join(" AND ")
  end
end
