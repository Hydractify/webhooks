defmodule Webhooks.Application do
  @moduledoc """
    Small application listening for webhooks notifications
  """

  use Application

  def start(_type, _args) do
    children = [
      {Redix, [[host: "127.0.0.1", port: 6379], [name: :redix]]},
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
