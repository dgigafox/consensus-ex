defmodule ConsensusEx.Monitoring do
  @moduledoc """
  A GenServer implementation that periodically (every T time) sends a message PING
  to the leader.
  """
  use GenServer

  alias ConsensusEx.LeaderRegistry

  @self __MODULE__

  @timeout Application.get_env(:consensus_ex, :settings)[:timeout]
  @refresh_time @timeout

  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: @self)
  end

  def stop() do
    GenServer.cast(@self, :stop)
  end

  def init(_default) do
    leader = LeaderRegistry.get_leader()
    state = %{node: leader, timer_ref: nil}

    unless leader == Node.self() || leader == nil do
      send(@self, {:send_message, state.node})
    end

    {:ok, state}
  end

  def handle_info({:send_message, leader} = msg, state) do
    timer_ref = schedule_message(msg)

    ConsensusEx.send_message(leader, "PING", @timeout * 4)

    state = %{state | timer_ref: timer_ref}
    {:noreply, state}
  end

  def handle_cast(:stop, state) do
    :timer.cancel(state.timer_ref)
    {:stop, :normal, state}
  end

  defp schedule_message(msg) do
    Process.send_after(self(), msg, @refresh_time)
  end
end
