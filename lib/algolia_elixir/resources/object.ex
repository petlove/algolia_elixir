defmodule AlgoliaElixir.Resources.Object do
  use AlgoliaElixir.Client

  def save_object(index, object), do: save_objects(index, [object])

  def save_objects(index, objects) do
    request_batch(index, "updateObject", objects)
  end

  def delete_object(index, object_id), do: delete_objects(index, [object_id])

  def delete_objects(index, object_ids) do
    request_batch(index, "deleteObject", object_ids)
  end

  def partil_update_object(index, object), do: partial_update_objects(index, [object])

  def partial_update_objects(index, objects) do
    request_batch(index, "partialUpdateObjectNoCreate", objects)
  end

  defp request_batch(index, action, objects) do
    requests = Enum.map(objects, &%{action: action, body: &1})

    execute_batch(index, requests)
  end

  def execute_batch(index, requests) do
    post("/indexes/#{index}/batch", %{requests: requests})
  end
end
