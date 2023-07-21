defmodule AlgoliaElixirTest.Middleware.BaseUrlWithRetryTest do
  use AlgoliaElixir.DataCase

  alias AlgoliaElixir.Middleware.BaseUrlWithRetry
  alias Tesla.Env

  test "build read url when subdomain is analytics" do
    assert {:ok, env} = BaseUrlWithRetry.call(%Env{url: ""}, [], subdomain: "analytics")
    assert env.url == "https://analytics.algolia.com/2"
  end

  test "build read url when action do not exist" do
    assert {:ok, env} = BaseUrlWithRetry.call(%Env{url: ""}, [], subdomain: "test-id")
    assert env.url == "https://test-id-dsn.algolia.net/1"
  end

  test "build read url when action is read" do
    assert {:ok, env} =
             BaseUrlWithRetry.call(%Env{url: "", opts: [action: :read]}, [], subdomain: "test-id")

    assert env.url == "https://test-id-dsn.algolia.net/1"
  end

  test "build write url when action is write" do
    assert {:ok, env} =
             BaseUrlWithRetry.call(%Env{url: "", opts: [action: :write]}, [], subdomain: "test-id")

    assert env.url == "https://test-id.algolia.net/1"
  end

  test "not retry when max_retries is 0" do
    assert {:ok, env} =
             BaseUrlWithRetry.call(%Env{url: "", opts: [action: :read]}, [],
               subdomain: "test-id",
               max_retries: 0,
               jitter_factor: 0.2,
               should_retry: fn _ -> true end
             )

    assert env.url == "https://test-id-dsn.algolia.net/1"
  end

  test "build read action fail 1 time must retry with url suffix -1" do
    assert {:ok, env} =
             BaseUrlWithRetry.call(%Env{url: "", opts: [action: :read]}, [],
               subdomain: "test-id",
               max_retries: 1,
               max_delay: 0,
               should_retry: fn _ -> true end
             )

    assert env.url == "https://test-id-1.algolia.net/1"
  end

  test "build read action fail 2 time must retry with url suffix -2" do
    assert {:ok, env} =
             BaseUrlWithRetry.call(%Env{url: "", opts: [action: :read]}, [],
               subdomain: "test-id",
               max_retries: 2,
               max_delay: 0,
               should_retry: fn _ -> true end
             )

    assert env.url == "https://test-id-2.algolia.net/1"
  end

  test "build read action fail 3 time must retry with url suffix -3" do
    assert {:ok, env} =
             BaseUrlWithRetry.call(%Env{url: "", opts: [action: :read]}, [],
               subdomain: "test-id",
               max_retries: 3,
               max_delay: 0,
               should_retry: fn _ -> true end
             )

    assert env.url == "https://test-id-3.algolia.net/1"
  end

  test "build read action fail 4 time must retry with url suffix -1" do
    assert {:ok, env} =
             BaseUrlWithRetry.call(%Env{url: "", opts: [action: :read]}, [],
               subdomain: "test-id",
               max_retries: 4,
               max_delay: 0,
               should_retry: fn _ -> true end
             )

    assert env.url == "https://test-id-1.algolia.net/1"
  end

  test "validate configs" do
    assert_raise ArgumentError, "option: subdomain is required", fn ->
      BaseUrlWithRetry.call(%Env{}, [], [])
    end

    assert_raise ArgumentError, "expected :delay to be an integer >= 0, got -1", fn ->
      BaseUrlWithRetry.call(%Env{}, [], subdomain: "test-id", delay: -1)
    end

    assert_raise ArgumentError,
                 "expected :jitter_factor to be a float >= 0 and <= 1, got -1",
                 fn ->
                   BaseUrlWithRetry.call(%Env{}, [], subdomain: "test-id", jitter_factor: -1)
                 end
  end
end
