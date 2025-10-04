defmodule Noumenon.Room do
  @moduledoc false

  use GenServer

  alias __MODULE__, as: Room

  def start_link({id, spec}) do
    GenServer.start_link(Room, {id, spec}, name: via(id))
  end

  defp via(id), do: {:via, Registry, {Noumenon.Registry, {:room, id}}}

  def init({id, spec}) do
    state = %{id: id, name: spec.name, desc: spec.desc, exits: spec.exits, players: MapSet.new()}
    {:ok, state}
  end

  def enter(room_id, player_name, player_pid),
    do: GenServer.call(via(room_id), {:enter, player_name, player_pid})

  def leave(room_id, player_name, player_pid),
    do: GenServer.call(via(room_id), {:leave, player_name, player_pid})

  def describe(room_id), do: GenServer.call(via(room_id), :describe)

  def say(room_id, from, msg), do: GenServer.cast(via(room_id), {:say, from, msg})

  def next_room(room_pid, dir), do: GenServer.call(room_pid, {:next_room, dir})

  def handle_call(:describe, _from, st) do
    who = st.players |> Enum.map(&elem(&1, 0)) |> Enum.sort()

    text =
      """
      #{st.name}
      #{st.desc}
      Exits: #{st.exits |> Map.keys() |> Enum.join(", ")}
      Here:  #{if who == [], do: "no one", else: Enum.join(who, ", ")}
      """

    {:reply, text, st}
  end

  def handle_call({:enter, name, pid}, _from, st) do
    broadcast(st, "* #{name} enters.")
    {:reply, :ok, %{st | players: MapSet.put(st.players, {name, pid})}}
  end

  def handle_call({:leave, name, pid}, _from, st) do
    broadcast(st, "* #{name} leaves.")
    {:reply, :ok, %{st | players: MapSet.delete(st.players, {name, pid})}}
  end

  def handle_call({:next_room, dir}, _from, st) do
    case Map.fetch(st.exits, dir) do
      {:ok, next} -> {:reply, {:ok, next}, st}
      :error -> {:reply, {:error, :no_exit}, st}
    end
  end

  def handle_cast({:say, from, msg}, st) do
    broadcast(st, "#{from} says: #{msg}")
    {:noreply, st}
  end

  defp broadcast(st, line) do
    Enum.each(st.players, fn {_name, pid} -> send(pid, {:room_msg, line}) end)
  end
end
