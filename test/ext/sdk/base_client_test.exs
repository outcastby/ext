defmodule Ext.Sdk.BaseClientTest do
  use ExUnit.Case
  import Mock
  require IEx

  @headers ["access-control-allow-origin": "*"]

  describe "get" do
    test "valid request" do
      with_mock(Ext.Sdk.BaseClient, [:passthrough], get: fn _, _, _ -> {:ok, %{body: "get test", status_code: 200}} end) do
        request = %Ext.Sdk.Request{
          headers: @headers,
          payload: %{
            test: "get_test"
          }
        }

        resp = Ext.Sdk.Test.Client.get_test(request)

        assert called(
                 Ext.Sdk.BaseClient.get(
                   "http://test/get_test",
                   ["Content-Type": "application/json"] ++ @headers,
                   params: %{test: "get_test"},
                   recv_timeout: 20_000,
                   timeout: 20_000
                 )
               )

        assert resp == {:ok, "get test"}
      end
    end

    test "error in response" do
      request = %Ext.Sdk.Request{
        headers: @headers,
        payload: %{
          test: "get_test"
        }
      }

      resp = Ext.Sdk.Test.Client.get_test(request)

      assert resp == {:error, "response: %HTTPoison.Error{id: nil, reason: :nxdomain}"}
    end

    test "invalid status_code" do
      with_mock(Ext.Sdk.BaseClient, [:passthrough], get: fn _, _, _ -> {:ok, %{body: "error", status_code: 400}} end) do
        request = %Ext.Sdk.Request{
          headers: @headers,
          payload: %{
            test: "get_test"
          }
        }

        resp = Ext.Sdk.Test.Client.get_test(request)

        assert called(
                 Ext.Sdk.BaseClient.get(
                   "http://test/get_test",
                   ["Content-Type": "application/json"] ++ @headers,
                   params: %{test: "get_test"},
                   recv_timeout: 20_000,
                   timeout: 20_000
                 )
               )

        assert resp == {:error, "error"}
      end
    end
  end

  describe "post" do
    test "valid request" do
      with_mock(Ext.Sdk.BaseClient, [:passthrough],
        post: fn _, _, _, _ -> {:ok, %{body: "post test", status_code: 200}} end
      ) do
        request = %Ext.Sdk.Request{
          headers: @headers,
          payload: %{
            test: "post_test"
          }
        }

        resp = Ext.Sdk.Test.Client.post_test(request)

        assert called(
                 Ext.Sdk.BaseClient.post(
                   "http://test/post_test",
                   "{\"test\":\"post_test\"}",
                   ["Content-Type": "application/json"] ++ @headers,
                   recv_timeout: 20_000,
                   timeout: 20_000
                 )
               )

        assert resp == {:ok, "post test"}
      end
    end
  end

  test "prepare_payload" do
    assert Ext.Sdk.BaseClient.prepare_payload(
             %{test: "post_test"},
             ["Content-Type": "application/x-www-form-urlencoded"] ++ @headers
           ) == {:form, [test: "post_test"]}
  end

  test "prepare_headers with map" do
    assert Ext.Sdk.BaseClient.prepare_headers(%{"access-control-allow-origin": "*"}) ==
             ["Content-Type": "application/json"] ++ @headers
  end
end
