defmodule Mix.Commands.Deploy.BuildArgsTest do
  use ExUnit.Case

  describe ".call" do
    test "test with skip tag release" do
      result =
        Mix.Commands.Deploy.BuildArgs.call(
          %Mix.Commands.Deploy.Context{
            version: nil,
            prev_version: nil,
            tag: "develop-test",
            prev_tag: nil,
            env_name: "uat"
          },
          false
        )

      assert result == %Mix.Commands.Deploy.Context{
               args: [
                 "-i",
                 "inventory",
                 "playbook.yml",
                 "--extra-vars",
                 "env_name=uat image_tag=develop-test version= prev_image_tag= prev_version=",
                 "--skip-tags",
                 "release"
               ],
               env_name: "uat",
               prev_tag: nil,
               prev_version: nil,
               tag: "develop-test",
               version: nil
             }
    end

    test "test with skip tag release and job" do
      result =
        Mix.Commands.Deploy.BuildArgs.call(
          %Mix.Commands.Deploy.Context{
            version: nil,
            prev_version: nil,
            tag: "develop-test",
            prev_tag: nil,
            env_name: "uat"
          },
          true
        )

      assert result == %Mix.Commands.Deploy.Context{
               args: [
                 "-i",
                 "inventory",
                 "playbook.yml",
                 "--extra-vars",
                 "env_name=uat image_tag=develop-test version= prev_image_tag= prev_version=",
                 "--skip-tags",
                 "release,job"
               ],
               env_name: "uat",
               prev_tag: nil,
               prev_version: nil,
               tag: "develop-test",
               version: nil
             }
    end

    test "test skip only tag job" do
      result =
        Mix.Commands.Deploy.BuildArgs.call(
          %Mix.Commands.Deploy.Context{
            version: "v0.2",
            prev_version: "v0.1",
            tag: "master-v0.2.0",
            prev_tag: "master-v0.1.0",
            env_name: "prod"
          },
          true
        )

      assert result == %Mix.Commands.Deploy.Context{
               args: [
                 "-i",
                 "inventory",
                 "playbook.yml",
                 "--extra-vars",
                 "env_name=prod image_tag=master-v0.2.0 version=v0.2 prev_image_tag=master-v0.1.0 prev_version=v0.1",
                 "--skip-tags",
                 "job"
               ],
               env_name: "prod",
               prev_tag: "master-v0.1.0",
               prev_version: "v0.1",
               tag: "master-v0.2.0",
               version: "v0.2"
             }
    end
  end
end
