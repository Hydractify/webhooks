defmodule Webhooks.Application do
  @moduledoc """
    Small application listening for webhooks notifications

    You can configure the redis connection by specifying valid
    `Redix.start_link/2` options under the environment key `:redis`.
    > Defaults to `host: "127.0.0.1", port: 6379`
  """

  use Application

  def start(_type, _args) do
    redis_opts = Application.get_env(:webhooks, :redis, host: "127.0.0.1", port: 6379)

    children = [
      {Redix, [redis_opts, [name: :redix]]},
      Plug.Adapters.Cowboy.child_spec(
        :http,
        Webhooks.Routers,
        [],
        port: 8080
      )
    ]

    opts = [strategy: :one_for_one]
    Supervisor.start_link(children, opts)
  end
end
