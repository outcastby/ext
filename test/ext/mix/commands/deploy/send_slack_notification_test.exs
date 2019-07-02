defmodule Mix.Commands.Deploy.SendSlackNotificationTest do
  use ExUnit.Case
  import Mock

  test ".call" do
    with_mock(Ext.Sdk.Slack.Client, send: fn _ -> "" end) do
      result =
        Mix.Commands.Deploy.SendSlackNotification.call(
          %Mix.Commands.Deploy.Context{
            version: nil,
            prev_version: nil,
            tag: "develop-test",
            prev_tag: nil,
            env_name: "uat"
          },
          :before
        )

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
