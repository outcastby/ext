defmodule Mix.Commands.Deploy.ContextTest do
  use ExUnit.Case
  import Mock

  describe ".init()" do
    test "uat environment" do
      result = Mix.Commands.Deploy.Context.init("uat", "test_tag")

      assert result == %Mix.Commands.Deploy.Context{
               tag: "test_tag",
               env_name: "uat",
               version: nil,
               prev_tag: nil,
               prev_version: nil,
               args: []
             }
    end

    test "prod environment" do
      with_mocks([
        {System, [],
         [cmd: fn _, _ -> {"{\"image\": {\"name\": \"master-v0.1.0\"}}", 0} end, find_executable: fn _ -> "" end]},
        {String, [], [replace: fn _, _, _ -> "" end]}
      ]) do
        result = Mix.Commands.Deploy.Context.init("prod", "master-v0.2.0")

        assert result == %Mix.Commands.Deploy.Context{
                 env_name: "prod",
                 tag: "master-v0.2.0",
                 version: "v0.2",
                 prev_tag: "master-v0.1.0",
                 prev_version: "v0.1",
                 args: []
               }
      end
    end
  end
end
