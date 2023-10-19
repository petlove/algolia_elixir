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

  defp format_params(params), do: URI.encode_query(params)

  defp format_filters(filters) when is_binary(filters), do: filters

  defp format_filters(filters) when is_map(filters) do
    filters
    |> Enum.reduce([], fn filter, acc ->
      acc ++ format_filter_value(filter)
    end)
    |> Enum.join(" AND ")
  end

  defp format_filter_value({_, ""}), do: []
  defp format_filter_value({_, []}), do: []
  defp format_filter_value({_, [""]}), do: []
  defp format_filter_value({name, values}) when is_binary(values), do: ["(#{name}:\"#{values}\")"]
  defp format_filter_value({name, values}) when is_boolean(values), do: ["(#{name}:\#{values}\)"]

  defp format_filter_value({name, %{"min" => min, "max" => max}})
       when is_binary(min) and is_binary(max) and min != "" and max != "",
       do: ["(#{name}:#{min} TO #{max})"]

  defp format_filter_value({name, values}) when is_list(values) do
    facet =
      Enum.map_join(values, " OR ", fn value ->
        "#{name}:\"#{value}\""
      end)

    ["(#{facet})"]
  end
end
