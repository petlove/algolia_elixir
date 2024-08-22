defmodule AlgoliaElixir.Resources.Rules do
  use AlgoliaElixir.Client

  def search_rules(index, params \\ %{}) do
    post("/indexes/#{index}/rules/search", params)
  end

  def batch_rules(index, rules) do
    post("/indexes/#{index}/rules/batch", rules)
  end
end
