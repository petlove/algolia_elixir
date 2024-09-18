defmodule AlgoliaElixir.Resources.Search do
  use AlgoliaElixir.Client

  def search(index, params), do: multi_search([%{indexName: index, params: params}])

  def multi_search(queries) do
    requests = Enum.map(queries, &format_query/1)

    post("/indexes/*/queries", %{requests: requests})
  end

  defp format_query(%{indexName: index, params: params}) do
    params
    |> format_params()
    |> Map.put(:indexName, index)
    |> Enum.reject(fn {_, value} -> is_nil(value) end)
    |> Enum.into(%{})
  end

  defp format_params(params) do
    params
    |> Map.put(:filters, format_filters(params[:filters]))
    |> Map.put(:analyticsTags, format_analytics_tags(params[:analyticsTags]))
    |> Map.put(:optionalFilters, format_optional_filters(params[:optionalFilters]))
  end

  defp format_filters(filters) when is_binary(filters), do: filters

  defp format_filters(filters) when is_map(filters) do
    filters
    |> Enum.reduce([], fn filter, acc ->
      acc ++ format_filter_value(filter)
    end)
    |> Enum.join(" AND ")
  end

  defp format_filters(_), do: nil

  defp format_analytics_tags(tags) when is_list(tags), do: Enum.join(tags, ",")
  defp format_analytics_tags(_), do: nil

  defp format_optional_filters([_ | _] = optional_filters), do: [optional_filters]
  defp format_optional_filters(_), do: nil

  defp format_filter_value({_, ""}), do: []
  defp format_filter_value({_, []}), do: []
  defp format_filter_value({_, [""]}), do: []
  defp format_filter_value({name, values}) when is_binary(values), do: ["(#{name}:\"#{values}\")"]
  defp format_filter_value({name, values}) when is_boolean(values), do: ["(#{name}:#{values})"]

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
