use Mix.Config

file_backends =
  cond do
    System.get_env("LOG_LEVEL") == "debug" ->
      [
        {LoggerFileBackend, :error_log},
        {LoggerFileBackend, :warn_log},
        {LoggerFileBackend, :info_log},
        {LoggerFileBackend, :debug_log}
      ]

    System.get_env("LOG_LEVEL") == "info" ->
      [{LoggerFileBackend, :error_log}, {LoggerFileBackend, :warn_log}, {LoggerFileBackend, :info_log}]

    System.get_env("LOG_LEVEL") == "warn" ->
      [{LoggerFileBackend, :error_log}, {LoggerFileBackend, :warn_log}]

    System.get_env("LOG_LEVEL") == "error" ->
      [{LoggerFileBackend, :error_log}]

    true ->
      []
  end

metadata = [:request_id, :sdk, :method, :url]
format = "$date $time $metadata[$level] $message\n"

config :logger,
  format: format,
  backends:
    [:console | file_backends] ++
      if(Code.ensure_compiled?(Rollbax), do: [{Ext.Logger.Rollbar.ErrorSend, :error_log}], else: [])

config :logger, :error_log,
  path: "log/error.log",
  format: format,
  metadata: metadata,
  level: :error

config :logger, :warn_log,
  path: "log/warn.log",
  format: format,
  metadata: metadata,
  level: :warn

config :logger, :info_log,
  path: "log/info.log",
  format: format,
  metadata: metadata,
  level: :info

config :logger, :debug_log,
  path: "log/debug.log",
  format: format,
  metadata: metadata,
  level: :debug

config :logger, :console,
  format: format,
  metadata: metadata
