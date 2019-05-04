defmodule Mix.Commands.Deploy.FindOrCreateBuildTest do
  use ExUnit.Case
  import Mock

  test ".call" do
    with_mocks([
      {System, [],
       [cmd: fn _, _ -> {"{\"image\": {\"name\": \"master-v0.1.0\"}}", 0} end, find_executable: fn _ -> "" end]}
    ]) do
      result =
        Mix.Commands.Deploy.FindOrCreateBuild.call(%Mix.Commands.Deploy.Context{
          version: nil,
          prev_version: nil,
          tag: "develop-test",
          prev_tag: nil,
          env_name: "uat"
        })

      assert result == %Mix.Commands.Deploy.Context{
               version: nil,
               prev_version: nil,
               tag: "develop-test",
               prev_tag: nil,
               env_name: "uat"
             }
    end
  end
end
