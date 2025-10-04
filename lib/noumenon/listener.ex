defmodule Noumenon.Listener do
  @moduledoc false

  use GenServer

  alias __MODULE__, as: Listener

  def start_link(port), do: GenServer.start_link(Listener, port, name: Listener)

  def init(port) do
    {:ok, socket} =
      :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])

    Task.start(fn -> accept_loop(socket) end)
    IO.puts("World of Noumenon listening on #{port}")
    {:ok, socket}
  end

  defp accept_loop(lsock) do
    {:ok, sock} = :gen_tcp.accept(lsock)
    Task.Supervisor.start_child(Noumenon.ConnSupervisor, fn -> Noumenon.Session.start(sock) end)
    accept_loop(lsock)
  end
end
