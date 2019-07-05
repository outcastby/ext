defmodule Ext.Gql.Resolvers.BaseTest do
  use ExUnit.Case
  import Mock
  require IEx

  test ".build_assoc_data" do
    test_assoc_list = [%TestAssoc{id: 1, field: "test1"}, %TestAssoc{id: 2, field: "test2"}]

    with_mock(TestRepo, [:passthrough],
      where: fn _, _ -> :_ end,
      all: fn _ -> test_assoc_list end
    ) do
      {entity_params, preload_assoc} =
        Ext.Gql.Resolvers.Base.build_assoc_data(TestUser, TestRepo, %{name: "test_name", test_assoc: [1, 2]})

      assert called(TestRepo.where(TestAssoc, id: [1, 2]))
      assert entity_params == %{name: "test_name", test_assoc: test_assoc_list}
      assert preload_assoc == [:test_assoc]
    end
  end
end
