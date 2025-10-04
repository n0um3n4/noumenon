defmodule Noumenon.Command do
  @moduledoc false

  alias Noumenon.{Room, World}

  def run("help", st) do
    msg = """
    Commands:
      look             – describe the room
      say <msg>        – chat to people in the room
      move <dir>       – go n/s/e/w
      who              – list players
      quit             – exit
    """

    {:ok, tell(st, msg)}
  end

  def run("look", st), do: {:ok, tell(st, Room.describe(st.room))}

  def run("who", st) do
    players =
      Registry.select(Noumenon.Registry, [{{{:player, :"$1"}, :_, :_}, [], [:"$1"]}])
      |> Enum.sort()

    {:ok, tell(st, "Players: " <> ((players == [] && "none") || Enum.join(players, ", ")))}
  end

  def run("quit", st), do: {:stop, st}

  def run("say", _st), do: {:error, "Nothing to say."}

  def run("say " <> rest, st) do
    case String.trim(rest) do
      "" ->
        {:error, "Nothing to say.", st}

      msg ->
        Noumenon.Room.say(st.world, st.room, "#{st.name} says: " <> msg)
        {:ok, st}
    end
  end

  def run("move " <> dir, st) do
    dir = String.downcase(String.trim(dir))

    case World.room_id_after_move(st.room, dir) do
      {:ok, next} ->
        Room.leave(st.room, st.name, self())
        Room.enter(next, st.name, self())
        {:ok, tell(%{st | room: next}, Room.describe(next))}

      {:error, :no_exit} ->
        {:error, "No exit that way.", st}

      other ->
        {:error, "Cannot move: #{inspect(other)}", st}
    end
  end

  def run(_, st), do: {:error, "Unknown command. Try 'help'.", st}

  defp tell(st, msg) do
    :gen_tcp.send(st.sock, msg <> "\r\n")
    st
  end
end
