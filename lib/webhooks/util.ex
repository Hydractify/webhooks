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
  def respond(conn, status, data \\ "") do
    {content_type, data} =
      if is_map(data) do
        {"application/json", Poison.encode!(data)}
      else
        {"plain/text", data}
      end

    conn
    |> put_resp_content_type(content_type)
    |> send_resp(status, data)
    |> halt
  end
end
