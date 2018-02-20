defmodule Webhooks.Routers do
  use Plug.{Debugger, ErrorHandler, Router}

  alias Webhooks.Plugs

  import Plug.Conn

  plug(Plug.Logger, log: :debug)
  plug(:match)

  plug(
    Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison
  )

  plug(:dispatch)

  forward "/webhooks/dbl/", to: Plugs.DBL

  match _ do
    send_resp(conn, 404, "not found")
  end

  def handle_errors(conn, error) do
    error = Poison.encode!(%{message: inspect(error.reason)})
    send_resp(conn, 500, error)
  end
end
