defmodule Noumenon.Application do
  @moduledoc false

  use Application

  @port 4040

  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: Noumenon.Registry},
      {DynamicSupervisor, name: Noumenon.RoomSupervisor, strategy: :one_for_one},
      {DynamicSupervisor, name: Noumenon.PlayerSupervisor, strategy: :one_for_one},
      {Task.Supervisor, name: Noumenon.ConnSupervisor},
      {Noumenon.Listener, @port},
      Noumenon.World
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Noumenon.Supervisor)
  end
end
