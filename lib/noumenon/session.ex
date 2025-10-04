defmodule Noumenon.Session do
  @moduledoc false

  @prompt "> "

  def start(sock) do
    :gen_tcp.send(sock, "Welcome to World of Noumenon!\r\nName: ")

    case :gen_tcp.recv(sock, 0) do
      {:ok, name_bin} ->
        name = String.trim(name_bin)

        {:ok, pid} =
          DynamicSupervisor.start_child(
            Noumenon.PlayerSupervisor,
            {Noumenon.Player, {name, sock}}
          )

        loop(sock, pid)

      {:error, _} ->
        :ok
    end
  end

  defp loop(sock, player_pid) do
    :gen_tcp.send(sock, @prompt)

    case :gen_tcp.recv(sock, 0) do
      {:ok, data} ->
        cmd = data |> String.trim()
        Noumenon.Player.command(player_pid, cmd)
        loop(sock, player_pid)

      {:error, _reason} ->
        Noumenon.Player.disconnect(player_pid)
        :ok
    end
  end
end
