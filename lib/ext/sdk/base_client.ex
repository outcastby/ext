defmodule Ext.Sdk.BaseClient do
  use HTTPoison.Base
  require IEx
  require Logger

  @timeout 20_000

  defmacro __using__(endpoints: endpoints) do
    quote bind_quoted: [endpoints: endpoints] do
      endpoints
      |> Enum.each(fn event ->
        def unquote(event)(request \\ nil) do
          {method_name, _} = __ENV__.function
          __MODULE__.method_missing(method_name, request)
        end
      end)

      @doc """
      Base url preparing
      Feel free to override this behaviour like you wish
      """
      def prepare_url(url), do: Ext.Sdk.BaseClient.prepare_url(__MODULE__, url)

      def method_missing(method_name, request), do: Ext.Sdk.BaseClient.method_missing(__MODULE__, method_name, request)

      @doc """
      Returns tuple of parameters.
      """
      def perform(method, url, payload \\ %{}, headers \\ [], options \\ %{}),
        do: Ext.Sdk.BaseClient.perform(__MODULE__, method, url, payload, headers, options)

      def gql(query, variables \\ nil), do: Ext.Sdk.BaseClient.gql(__MODULE__, query, variables)

      def handle_response(response, status), do: Ext.Sdk.BaseClient.handle_response(response, status)

      def config, do: Ext.Sdk.BaseClient.config(__MODULE__)

      def name, do: Ext.Sdk.BaseClient.name(__MODULE__)

      def prepare_headers(headers), do: Ext.Sdk.BaseClient.prepare_headers(headers)

      def prepare_payload(payload, headers), do: Ext.Sdk.BaseClient.prepare_payload(payload, headers)

      defoverridable prepare_headers: 1, handle_response: 2
    end
  end

  def prepare_url(module, url), do: config(module).base_url <> url

  def method_missing(module, method_name, %Ext.Sdk.Request{headers: headers, payload: payload, options: options}) do
    call_missing(module, method_name, payload, headers, options)
  end

  def method_missing(module, method_name, nil) do
    call_missing(module, method_name, %{}, [], %{})
  end

  @doc """
  Returns tuple of parameters.
  """
  def call_missing(module, method_name, payload, headers, options) do
    case config(module) do
      %{endpoints: %{^method_name => %{url: url, type: type}}} ->
        url = if is_binary(url), do: url, else: url.(options.url_params)
        perform(module, type, url, payload, headers, options)

      _ ->
        handle_error("Endpoint for #{inspect(method_name)} is not found")
    end
  end

  def perform(module, method, url, payload, headers, options) do
    headers = module.prepare_headers(headers)

    url = apply(module, :prepare_url, get_url_params(module, url, options))

    Logger.metadata(sdk_name: name(module), method: method, process_url: process_url(url))

    Logger.info("request: #{inspect(payload)}, headers: #{inspect(headers)}")

    case perform_request(method, url, payload, headers) do
      {:error, resp} ->
        handle_error("response: #{inspect(resp)}")

      {:ok, %{body: body, status_code: status_code} = resp} ->
        Logger.info("response: #{inspect(resp)}")

        cond do
          status_code >= 400 -> module.handle_response(body, :error)
          true -> module.handle_response(body, :ok)
        end
    end
  end

  defp get_url_params(module, url, options) do
    case :erlang.function_exported(module, :prepare_url, 2) do
      true -> [url, options]
      _ -> [url]
    end
  end

  defp perform_request(:get, url, payload, headers),
    do: get(url, headers, params: payload, recv_timeout: @timeout, timeout: @timeout)

  defp perform_request(method, url, payload, headers),
    do:
      apply(__MODULE__, method, [
        url,
        prepare_payload(payload, headers),
        headers,
        [recv_timeout: @timeout, timeout: @timeout]
      ])

  def gql(module, query, variables) do
    Neuron.Config.set(url: config(module).base_url <> config(module).gql_path)
    Neuron.Config.set(connection_opts: [recv_timeout: @timeout, timeout: @timeout])
    {:ok, %Neuron.Response{body: body}} = Neuron.query(query, variables)
    {:ok, body["data"]}
  end

  def handle_response(response, status) do
    try do
      {status, response |> Poison.decode!()}
    rescue
      _ -> {status, response}
    end
  end

  def handle_error(message, metadata \\ []) do
    Logger.error(inspect(message), metadata)
    {:error, message}
  end

  def config(module) do
    modules = module |> to_string |> String.split(".")
    config_module_name = (Enum.drop(modules, -1) ++ ["Config"]) |> Enum.join(".")
    String.to_existing_atom(config_module_name).data
  end

  def name(module), do: config(module).sdk_name

  def prepare_headers(headers), do: ["Content-Type": "application/json"] ++ headers

  def prepare_payload(payload, [{_, content_type} | _]) when content_type == "application/x-www-form-urlencoded",
    do: {:form, Enum.to_list(payload)}

  def prepare_payload(payload, _), do: Poison.encode!(payload)
end
