use Mix.Config

metadata = [:request_id, :sdk, :method, :url]
format = "$date $time $metadata[$level] $message\n"

config :logger,
  format: format,
  backends: [:console, LoggerLagerBackend, {Ext.Logger.Rollbar.ErrorSend, :error_log}]

config :logger, :console,
  format: format,
  metadata: metadata

config :lager,
  handlers: [
    lager_file_backend: [
      file: 'log/debug.log',
      level: :debug,
      size: 10_485_760,
      date: '$D0',
      count: 2
    ],
    lager_file_backend: [
      file: 'log/info.log',
      level: :info,
      size: 10_485_760,
      date: '$D0',
      count: 2
    ],
    lager_file_backend: [
      file: 'log/warn.log',
      level: :warning,
      size: 10_485_760,
      date: '$D0',
      count: 2
    ],
    lager_file_backend: [
      file: 'log/error.log',
      level: :error,
      size: 10_485_760,
      date: '$D0',
      count: 2
    ]
  ],
  colored: true,
  crash_log: 'log/crash.log',
  crash_log_msg_size: 65536,
  crash_log_size: 10_485_760,
  crash_log_date: '$D0',
  crash_log_count: 2
