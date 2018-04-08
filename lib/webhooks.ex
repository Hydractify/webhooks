defmodule Webhooks.Application do
  @moduledoc """
    Small application listening for webhooks notifications

    You can specify a custom redis url by setting the `REDIS_URL` environment variable.
    > Defaults to "redis://localhost:6379"

    You can specify the port under which Cowboy will listen to by setting the `PORT` environment variable.
    > Defaults to `8080`
  """

  use Application

  def start(_type, _args) do
    redis_opts = System.get_env("REDIS_URL") || "redis://localhost:6379"
    port = System.get_env("PORT") || 8080

    children = [
      {Redix, [redis_opts, [name: :redix]]},
      Plug.Adapters.Cowboy.child_spec(
        :http,
        Webhooks.Routers,
        [],
        port: port
      )
    ]

    opts = [strategy: :one_for_one]
    Supervisor.start_link(children, opts)
  end
end
