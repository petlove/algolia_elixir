defmodule AlgoliaElixirTest.Resources.SearchTest do
  use AlgoliaElixir.DataCase

  alias AlgoliaElixir.Resources.Search

  import Tesla.Mock

  @url "https://test-dsn.algolia.net/1/indexes/*/queries"
  @browse_url "https://test-dsn.algolia.net/1/indexes/my_index/browse"

  test "search" do
    %{name: name} = object = build(:object)
    result = %{results: [build(:search_result, hits: [object])]}

    mock(fn %{method: :post, url: @url, body: body} ->
      assert body ==
               "{\"requests\":[{\"filters\":\"(ages:\\\"old\\\") AND (brand:\\\"brand1\\\" OR brand:\\\"brand2\\\")\",\"indexName\":\"my_index\",\"query\":\"term\"}]}"

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
      assert body ==
               "{\"requests\":[{\"filters\":\"(ages:old) AND (brand:brand1 OR brand:brand2)\",\"indexName\":\"my_index\",\"query\":\"term\"}]}"

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
      assert body ==
               "{\"requests\":[{\"indexName\":\"index1\",\"query\":\"term1\"},{\"indexName\":\"index2\",\"query\":\"term2\"}]}"

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

  test "browse_records with empty params" do
    %{name: name} = object = build(:object)
    result = build(:search_result, hits: [object])

    mock(fn %{method: :post, url: @browse_url, body: body} ->
      assert body == "{}"
      json(result)
    end)

    assert {:ok, %{status: 200, body: %{"hits" => [%{"name" => ^name}]}}} =
             Search.browse_records("my_index")
  end

  test "browse_records with page, hitsPerPage and attributesToRetrieve" do
    %{name: name} = object = build(:object)
    result = build(:search_result, hits: [object])

    mock(fn %{method: :post, url: @browse_url, body: body} ->
      decoded = Jason.decode!(body)
      assert decoded["page"] == 2
      assert decoded["hitsPerPage"] == 100
      assert decoded["attributesToRetrieve"] == ["objectID", "name"]
      json(result)
    end)

    assert {:ok, %{status: 200, body: %{"hits" => [%{"name" => ^name}]}}} =
             Search.browse_records("my_index", %{
               page: 2,
               hitsPerPage: 100,
               attributesToRetrieve: ["objectID", "name"]
             })
  end

  test "browse_records with cursor for next page" do
    %{name: name} = object = build(:object)
    result = build(:search_result, hits: [object])

    mock(fn %{method: :post, url: @browse_url, body: body} ->
      decoded = Jason.decode!(body)
      assert decoded["cursor"] == "jMDY3M2MwM2QwMWUxMmQwYWI0ZTN"
      json(result)
    end)

    assert {:ok, %{status: 200, body: %{"hits" => [%{"name" => ^name}]}}} =
             Search.browse_records("my_index", %{cursor: "jMDY3M2MwM2QwMWUxMmQwYWI0ZTN"})
  end

  test "browse_records formats filters like search" do
    %{name: name} = object = build(:object)
    result = build(:search_result, hits: [object])

    mock(fn %{method: :post, url: @browse_url, body: body} ->
      decoded = Jason.decode!(body)
      assert decoded["query"] == ""
      assert decoded["filters"] =~ "category"
      assert decoded["filters"] =~ "Book"
      assert decoded["filters"] =~ "brand"
      assert decoded["filters"] =~ "b1"
      assert decoded["filters"] =~ "b2"
      json(result)
    end)

    assert {:ok, %{status: 200, body: %{"hits" => [%{"name" => ^name}]}}} =
             Search.browse_records("my_index", %{
               query: "",
               filters: %{category: "Book", brand: ["b1", "b2"]}
             })
  end
end
