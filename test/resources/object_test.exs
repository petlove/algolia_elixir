defmodule AlgoliaElixirTest.Resources.ObjectTest do
  use AlgoliaElixir.DataCase

  alias AlgoliaElixir.Resources.Object

  import Tesla.Mock

  @url "https://test-dsn.algolia.net/1/indexes/my_index/batch"

  test "save_objects" do
    objects = build_list(3, :object)
    ids = Enum.map(objects, & &1[:objectID])

    mock(fn %{method: :post, url: @url, body: body} ->
      assert body =~ "updateObject"

      json(%{"objectIDs" => ids})
    end)

    assert {:ok, %{status: 200, body: %{"objectIDs" => ^ids}}} =
             Object.save_objects("my_index", objects)
  end

  test "save_object" do
    %{objectID: id} = object = build(:object)

    mock(fn %{method: :post, url: @url, body: body} ->
      assert body =~ "updateObject"

      json(%{"objectIDs" => [id]})
    end)

    assert {:ok, %{status: 200, body: %{"objectIDs" => [^id]}}} =
             Object.save_object("my_index", object)
  end

  test "delete_objects" do
    objects = build_list(3, :object)
    ids = Enum.map(objects, & &1[:objectID])

    mock(fn %{method: :post, url: @url, body: body} ->
      assert body =~ "deleteObject"

      json(%{"objectIDs" => ids})
    end)

    assert {:ok, %{status: 200, body: %{"objectIDs" => ^ids}}} =
             Object.delete_objects("my_index", objects)
  end

  test "delete_object" do
    %{objectID: id} = object = build(:object)

    mock(fn %{method: :post, url: @url, body: body} ->
      assert body =~ "deleteObject"

      json(%{"objectIDs" => [id]})
    end)

    assert {:ok, %{status: 200, body: %{"objectIDs" => [^id]}}} =
             Object.delete_object("my_index", object)
  end
end
