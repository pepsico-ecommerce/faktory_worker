defmodule FaktoryWorker.PoolTest do
  use ExUnit.Case

  alias FaktoryWorker.Pool

  describe "child_spec/1" do
    test "should return a default child_spec" do
      opts = [name: FaktoryWorker]
      child_spec = Pool.child_spec(opts)

      assert child_spec == default_child_spec()
    end

    test "should allow a custom name to be specified" do
      opts = [
        name: :my_test_faktory
      ]

      child_spec = Pool.child_spec(opts)
      config = get_child_spec_config(child_spec)

      assert config[:name] == {:local, :my_test_faktory_pool}
    end

    test "should allow pool config to be specified" do
      opts = [
        name: FaktoryWorker,
        pool: [
          size: 25
        ]
      ]

      child_spec = Pool.child_spec(opts)
      config = get_child_spec_config(child_spec)

      assert config[:size] == 25
      assert config[:max_overflow] == 25
    end
  end

  describe "format_pool_name/1" do
    test "should append a suffix to the given name" do
      assert :my_test_pool == Pool.format_pool_name(:my_test)
    end
  end

  defp default_child_spec() do
    {FaktoryWorker_pool,
     {:poolboy, :start_link,
      [
        [
          name: {:local, FaktoryWorker_pool},
          worker_module: FaktoryWorker.ConnectionManager.Server,
          size: 10,
          max_overflow: 10
        ],
        []
      ]}, :permanent, 5000, :worker, [:poolboy]}
  end

  defp get_child_spec_config(child_spec) do
    {_,
     {:poolboy, :start_link,
      [
        config,
        []
      ]}, :permanent, 5000, :worker, [:poolboy]} = child_spec

    config
  end
end
