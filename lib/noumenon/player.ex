defmodule Noumenon.Player do
  @moduledoc false

  use GenServer

  alias __MODULE__, as: Player

  def start_link({name, sock}) do
    GenServer.start_link(Player, {name, sock})
  end

  def command(pid, line), do: GenServer.cast(pid, {:command, line})
  def disconnect(pid), do: GenServer.cast(pid, :disconnect)

  def init({name, sock}) do
    Process.flag(:trap_exit, true)
    Registry.register(Noumenon.Registry, {:player, name}, %{})
    state = %{name: name, sock: sock, room: "start"}
    :gen_tcp.send(sock, "Hello #{name}. Type 'help' for commands.\r\n")
    Noumenon.Room.enter(state.room, name, self())
    send(self(), :describe)
    {:ok, state}
  end

  def handle_info(:describe, st) do
    desc = Noumenon.Room.describe(st.room)
    tx(st, desc)
    {:noreply, st}
  end

  def handle_info({:room_msg, line}, st) do
    tx(st, line)
    {:noreply, st}
  end

  def handle_cast(:disconnect, st), do: {:stop, :normal, st}

  def handle_cast({:command, ""}, st), do: {:noreply, st}

  def handle_cast({:command, line}, st) do
    case Noumenon.Command.run(line, st) do
      {:ok, st2} ->
        {:noreply, st2}

      {:stop, st2} ->
        {:stop, :normal, st2}

      {:error, msg, st2} ->
        tx(st2, msg)
        {:noreply, st2}
    end
  end

  def terminate(_reason, st) do
    Noumenon.Room.leave(st.room, st.name, self())
    :gen_tcp.send(st.sock, "Goodbye!\r\n")
    :gen_tcp.close(st.sock)
    :ok
  end

  defp tx(st, msg), do: :gen_tcp.send(st.sock, msg <> "\r\n")
end
