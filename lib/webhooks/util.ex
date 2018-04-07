defmodule Webhooks.Util do
  @moduledoc """
    Collection of useful functions / shortcuts
  """
  import Plug.Conn

  @doc """
    Does the following:
    - Stringifies map if necessary
    - Sets appropriate content-type
    - Sends the response
    - Halts the connection
    - Returns the connection
  """
  def respond(conn, status, data \\ "")

  def respond(conn, status, data) when is_bitstring(data),
    do: do_respond(conn, status, "plain/text", data)

  def respond(conn, status, data) when is_map(data),
    do: do_respond(conn, status, "application/json", Poison.encode!(data))

  defp do_respond(conn, status, content_type, data) do
    conn
    |> put_resp_content_type(content_type)
    |> send_resp(status, data)
    |> halt
  end
end
