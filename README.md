# Ext

## Installation

```elixir
def deps do
  [
    {:ext, git: "https://github.com/outcastby/ext.git"}
  ]
end
```

## Ext.Sdk.BaseClient
Add `:sdk_name, :method, :process_url` to metadata of logger console configuration.
```elixir
# config.exs
config :logger, :console,
  format: "$date $time $metadata[$level] $message\n",
  metadata: [:sdk_name, :method, :process_url]
```

