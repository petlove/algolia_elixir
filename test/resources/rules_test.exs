defmodule AlgoliaElixirTest.Resources.RulesTest do
  use AlgoliaElixir.DataCase

  alias AlgoliaElixir.Resources.Rules

  import Tesla.Mock

  test "search rules" do
    rules = build(:rule_result)

    mock(fn %{method: :post, url: "https://test-dsn.algolia.net/1/indexes/my_index/rules/search"} ->
      json(rules)
    end)

    assert {:ok, %{status: 200, body: ^rules}} = Rules.search_rules("my_index")
  end

  test "search rules failure" do
    response = %{"message" => "indexName is not valid", "status" => 400}

    mock(fn %{method: :post, url: "https://test-dsn.algolia.net/1/indexes//rules/search"} ->
      json(response)
    end)

    assert {:ok, %{status: 200, body: ^response}} = Rules.search_rules("")
  end

  test "batch rules success" do
    rules = build_list(5, :rule)
    response = %{"taskID" => 1_718_439_032_100, "updatedAt" => "2024-08-22T16:24:03.079Z"}

    mock(fn %{method: :post, url: "https://test-dsn.algolia.net/1/indexes/my_index/rules/batch"} ->
      json(response)
    end)

    assert {:ok, %{status: 200, body: ^response}} = Rules.batch_rules("my_index", rules)
  end

  test "batch rules failure" do
    response = %{
      "message" => "Missing mandatory attribute `objectID` (in `[0]`) (near 1:4)",
      "status" => 400
    }

    mock(fn %{method: :post, url: "https://test-dsn.algolia.net/1/indexes/my_index/rules/batch"} ->
      json(response)
    end)

    assert {:ok, %{status: 200, body: ^response}} = Rules.batch_rules("my_index", [])
  end
end
