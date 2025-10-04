defmodule Noumenon.World do
  @moduledoc false

  use GenServer

  alias __MODULE__, as: World

  @rooms %{
    "start" => %{
      name: "Docking Bay",
      desc: "Oil, ozone, and distant thunder.",
      exits: %{"n" => "hall"}
    },
    "hall" => %{
      name: "Observation Hall",
      desc: "Stars peel past the glass.",
      exits: %{"s" => "start", "e" => "lab"}
    },
    "lab" => %{name: "Quiet Lab", desc: "Hums with dormant machines.", exits: %{"w" => "hall"}}
  }

  def start_link(_), do: GenServer.start_link(World, :ok, name: World)

  def init(:ok) do
    Enum.each(@rooms, fn {id, spec} ->
      DynamicSupervisor.start_child(Noumenon.RoomSupervisor, {Noumenon.Room, {id, spec}})
    end)

    {:ok, :ready}
  end

  def room_id_after_move(current_id, dir) do
    case Registry.lookup(Noumenon.Registry, {:room, current_id}) do
      [{pid, _}] ->
        Noumenon.Room.next_room(pid, dir)

      _ ->
        {:error, :no_room}
    end
  end
end
