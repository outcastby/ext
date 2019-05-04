defmodule Mix.Tasks.Ext.DeployTest do
  use ExUnit.Case
  import Mock

  describe ".run" do
    test "start deploy uat without fast" do
      with_mocks([
        {System, [],
         [
           cmd: fn _, _ -> {"{\"image\": {\"name\": \"master-v0.1.0\"}}", 0} end,
           find_executable: fn _ -> "" end,
           get_env: fn _ -> "" end
         ]},
        {Ext.Shell, [], [exec: fn _, _, _ -> "" end]}
      ]) do
        result = Mix.Tasks.Ext.Deploy.run(["uat", "develop-test"])

        assert result == %Mix.Commands.Deploy.Context{
                 env_name: "uat",
                 prev_tag: nil,
                 prev_version: nil,
                 tag: "develop-test",
                 version: nil,
                 args: [
                   "-i",
                   "inventory",
                   "playbook.yml",
                   "--extra-vars",
                   "env_name=uat image_tag=develop-test version= prev_image_tag= prev_version=",
                   "--skip-tags",
                   "release"
                 ]
               }
      end
    end

    test "start deploy uat with fast" do
      with_mocks([
        {System, [],
         [
           cmd: fn _, _ -> {"{\"image\": {\"name\": \"master-v0.1.0\"}}", 0} end,
           find_executable: fn _ -> "" end,
           get_env: fn _ -> "" end
         ]},
        {Ext.Shell, [], [exec: fn _, _, _ -> "" end]}
      ]) do
        result = Mix.Tasks.Ext.Deploy.run(["uat", "develop-test", "-f"])

        assert result == %Mix.Commands.Deploy.Context{
                 env_name: "uat",
                 prev_tag: nil,
                 prev_version: nil,
                 tag: "develop-test",
                 version: nil,
                 args: [
                   "-i",
                   "inventory",
                   "playbook.yml",
                   "--extra-vars",
                   "env_name=uat image_tag=develop-test version= prev_image_tag= prev_version=",
                   "--skip-tags",
                   "release,job"
                 ]
               }
      end
    end

    test "start deploy prod" do
      with_mocks([
        {System, [],
         [
           cmd: fn _, _ -> {"{\"image\": {\"name\": \"master-v0.1.0\"}}", 0} end,
           find_executable: fn _ -> "" end,
           get_env: fn _ -> "" end
         ]},
        {Ext.Commands.SendToSlack, [], [call: fn _, _, _ -> "" end]},
        {Ext.Shell, [], [exec: fn _, _, _ -> "" end]},
        {String, [], [replace: fn _, _, _ -> "" end]}
      ]) do
        result = Mix.Tasks.Ext.Deploy.run(["prod", "master-v0.2.0"])

        assert result == %Mix.Commands.Deploy.Context{
                 env_name: "prod",
                 prev_tag: "master-v0.1.0",
                 prev_version: "v0.1",
                 tag: "master-v0.2.0",
                 version: "v0.2",
                 args: [
                   "-i",
                   "inventory",
                   "playbook.yml",
                   "--extra-vars",
                   "env_name=prod image_tag=master-v0.2.0 version=v0.2 prev_image_tag=master-v0.1.0 prev_version=v0.1"
                 ]
               }
      end
    end
  end
end
