defmodule AlgoliaElixir.DataCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import AlgoliaElixir.Factory
    end
  end
end
