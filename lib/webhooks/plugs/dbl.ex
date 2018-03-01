defmodule Webhooks.Plugs.DBL do
  @moduledoc """
    Plug listening specifically for Webhooks from http://discordbots.org
    See: https://discordbots.org/api/docs#webhooks

    Required for this to run are:
      An entry in the config.exs or an environment variable of
        - :dbl_secret / DBL_SECRET || A secret to match against, verifying the notification actually comes from dbl
        - :bot_id / BOT_ID || The id of the bot to expect incoming notifications from
  """

  alias Webhooks.Util

  @local_secret_missing %{"message" => "No local \"secret\" to match against"}
  @remote_secret_missing %{"message" => "Missing \"secret\" query string parameter"}
  @invalid_secret %{"message" => "Invalid secret provided"}
  @missing_params %{
    "message" =>
      "Malformed post payload, expected it to have at least \"bot\", \"user\", and \"body\""
  }
  @missing_bot %{"message" => "No local \"bot\" to match against"}
  @invalid_bot %{
    "message" => "Invalid post payload, unexpected \"bot\" id"
  }
  @invalid_type %{
    "message" => "Malformed post payload, expected \"type\" to be one of \"upvote\" and \"none\""
  }

  def init(opts), do: opts

  def call(conn, _opts) do
    # Fetch secret sent via the post request
    with {:ok, remote_secret} <- fetch_remote_secret(conn),
         # Fetch local secret from env or config
         {:ok, local_secret} <- fetch_local(:dbl_secret, @local_secret_missing),
         # Compare those secrets
         true <- remote_secret == local_secret || {:error, 401, @invalid_secret},
         # Fetch body params
         %{"bot" => remote_bot, "type" => type, "user" => user} <- conn.params,
         # Fetch the bot from env or config
         {:ok, local_bot} <- fetch_local(:bot_id, @missing_bot),
         # Compare bot ids
         true <- remote_bot == local_bot || {:error, 400, @invalid_bot},
         # Valid the type
         true <- type in ["upvote", "none"] || {:error, 400, @invalid_type} do
      case type do
        "upvote" ->
          # One may upvote daily, so expire it after 24 hours
          Redix.command!(:redix, ["SETEX", "DBL:#{user}", 24 * 60 * 60, "1"])

        "none" ->
          # Unvoted, removing from voters
          Redix.command!(:redix, ["DEL", "DBL:#{user}"])
      end

      conn
      |> Util.respond(204)
    else
      {:error, status, data} ->
        conn
        |> Util.respond(status, data)

      # Params missing
      _ ->
        conn
        |> Util.respond(400, @missing_params)
    end
  end

  defp fetch_local(atom, error) do
    env_key =
      atom
      |> to_string
      |> String.upcase()

    with nil <- System.get_env(env_key),
         nil <- Application.get_env(:webhooks, atom) do
      require Logger

      error
      |> inspect
      |> Logger.warn()

      {:error, 500, error}
    else
      value ->
        {:ok, value}
    end
  end

  defp fetch_remote_secret(conn) do
    case List.keyfind(conn.req_headers, "authorization", 0) do
      {"authorization", authorization} ->
        {:ok, authorization}

      _ ->
        {:error, 401, @remote_secret_missing}
    end
  end
end
