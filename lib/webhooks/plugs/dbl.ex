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

  @dbl_secret :dbl_secret
  @bot_id :bot_id

  @remote_secret_missing %{"message" => "Missing \"authorization\" header"}
  @local_secret_missing %{"message" => "No local \"secret\" to match against"}
  @invalid_secret %{"message" => "Invalid secret provided"}

  @missing_remote_bot %{"message" => "Malformed post payload, missing \"bot\" key"}
  @missing_local_bot %{"message" => "No local \"bot\" to match against"}
  @invalid_bot_id %{"message" => "Invalid post payload, incorrect \"bot\" id"}

  @missing_params %{
    "message" =>
      "Malformed post payload, expected it to have at least \"bot\", \"user\", and \"type\""
  }
  @invalid_type %{
    "message" => "Malformed post payload, expected \"type\" to be one of \"upvote\" and \"test\""
  }

  def init(opts), do: opts

  def call(conn, _opts) do
    # Validate remote and local secrets
    with :ok <- validate_secret(conn),
         # Validate remote and local bot ids
         :ok <- validate_bot_id(conn.params),
         # Fetch body params, the "test" type is incredible useful as only the owners may test...
         %{"type" => type, "user" => user} when type in ["test", "upvote"] <- conn.params do
      Redix.command!(:redix, ["SETEX", "DBL:#{user}", 24 * 60 * 60, "1"])

      Util.respond(conn, 204)
    else
      {:error, status, data} ->
        Util.respond(conn, status, data)

      %{"type" => _type, "user" => _user} ->
        Util.respond(conn, 400, @invalid_type)

      %{} ->
        Util.respond(conn, 400, @missing_params)
    end
  end

  defp validate_bot_id(%{"bot" => remote}) do
    with {:ok, local} <- fetch_local(@bot_id, @missing_local_bot) do
      if remote == local,
        do: :ok,
        else: {:error, 400, @invalid_bot_id}
    end
  end

  defp validate_bot_id(%{}), do: {:error, 400, @missing_remote_bot}

  defp validate_secret(%{req_headers: headers}) do
    with {"authorization", remote} <-
           List.keyfind(headers, "authorization", {:error, 401, @remote_secret_missing}),
         {:ok, local} <- fetch_local(@dbl_secret, @local_secret_missing) do
      if remote == local,
        do: :ok,
        else: {:error, 401, @invalid_secret}
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
end
