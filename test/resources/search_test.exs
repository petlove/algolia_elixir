defmodule AlgoliaElixirTest.Resources.SearchTest do
  use AlgoliaElixir.DataCase

  alias AlgoliaElixir.Resources.Search

  import Tesla.Mock

  @url "https://test-dsn.algolia.net/1/indexes/*/queries"

  test "search" do
    %{name: name} = object = build(:object)
    result = %{results: [build(:search_result, hits: [object])]}

    mock(fn %{method: :post, url: @url, body: body} ->
      assert body =~
               URI.encode_query(%{"filters" => "(ages:old) AND (brand:brand1 OR brand:brand2)"})

      assert body =~ "query=term"

      json(result)
    end)

    assert {:ok, %{status: 200, body: %{"results" => [%{"hits" => [%{"name" => ^name}]}]}}} =
             Search.search("my_index", %{
               query: "term",
               filters: %{brand: ["brand1", "brand2"], ages: "old"}
             })
  end

  test "search with query already encoded" do
    %{name: name} = object = build(:object)
    result = %{results: [build(:search_result, hits: [object])]}

    mock(fn %{method: :post, url: @url, body: body} ->
      assert body =~
               URI.encode_query(%{"filters" => "(ages:old) AND (brand:brand1 OR brand:brand2)"})

      assert body =~ "query=term"

      json(result)
    end)

    assert {:ok, %{status: 200, body: %{"results" => [%{"hits" => [%{"name" => ^name}]}]}}} =
             Search.search("my_index", %{
               query: "term",
               filters: "(ages:old) AND (brand:brand1 OR brand:brand2)"
             })
  end

  test "multi_search" do
    queries = [
      %{indexName: "index1", params: %{query: "term1"}},
      %{indexName: "index2", params: %{query: "term2"}}
    ]

    %{name: name1} = object1 = build(:object)
    %{name: name2} = object2 = build(:object)

    result = %{
      results: [
        build(:search_result, hits: [object1]),
        build(:search_result, hits: [object2])
      ]
    }

    mock(fn %{method: :post, url: @url, body: body} ->
      assert body =~ "query=term1"
      assert body =~ "query=term2"

      json(result)
    end)

    assert {:ok,
            %{
              status: 200,
              body: %{
                "results" => [
                  %{"hits" => [%{"name" => ^name1}]},
                  %{"hits" => [%{"name" => ^name2}]}
                ]
              }
            }} = Search.multi_search(queries)
  end
end
