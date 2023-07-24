defmodule AlgoliaElixirTest.Resources.AnalyticsTest do
  use AlgoliaElixir.DataCase

  alias AlgoliaElixir.Resources.Analytics

  import Tesla.Mock

  @url "https://analytics.algolia.com/2/searches"

  describe "top_searches/2" do
    test "get top searches" do
      searches = build_list(5, :search)

      mock(fn %{method: :get, url: @url} ->
        json(%{"searches" => searches})
      end)

      assert {:ok, %{status: 200, body: %{"searches" => ^searches}}} =
               Analytics.top_searches("my_index")
    end
  end
end
