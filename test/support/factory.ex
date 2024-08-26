defmodule AlgoliaElixir.Factory do
  use ExMachina

  def object_factory do
    %{
      objectID: Faker.Code.isbn(),
      name: Faker.Beer.name()
    }
  end

  def search_factory do
    %{
      "search" => Faker.Beer.name(),
      "count" => Faker.Random.Elixir.random_between(1, 10_000),
      "nbHits" => Faker.Random.Elixir.random_between(1, 2_000)
    }
  end

  def search_result_factory do
    %{
      exhaustiveNbHits: true,
      exhaustiveTypo: true,
      hits: build_list(3, :object),
      hitsPerPage: 20,
      index: "variants",
      nbHits: 0,
      nbPages: 0,
      page: 0,
      params: "query=vsd",
      processingTimeMS: 1,
      query: "vsd",
      renderingContent: %{}
    }
  end

  def rule_factory do
    %{
      "_metadata" => %{"lastUpdate" => 1_724_161_095},
      "conditions" => [
        %{
          "pattern" => %{
            "matchLevel" => "none",
            "matchedWords" => [],
            "value" => Faker.Commerce.product_name()
          }
        }
      ],
      "consequence" => %{
        "filterPromotes" => true,
        "promote" => [
          %{
            "objectIDs" => ["#{Faker.Random.Elixir.random_between(100_000, 200_000)}"],
            "position" => 1
          }
        ]
      },
      "description" => Faker.Lorem.sentence(),
      "enabled" => true,
      "objectID" => "qr-#{Faker.Random.Elixir.random_between(100_000, 200_000)}",
      "tags" => ["visual-editor"]
    }
  end

  def rule_result_factory do
    %{
      "hits" => build_list(3, :rule),
      "nbHits" => 484,
      "nbPages" => 484,
      "page" => 0
    }
  end
end
