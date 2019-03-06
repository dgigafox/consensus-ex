defmodule ConsensusEx.EventHandler do
  use Agent

  alias ConsensusEx.LeaderRegistry

  @self __MODULE__

  def start_link do
    Agent.start_link(fn -> %{state: nil} end, name: @self)
  end

  def switch_state do
    Agent.update(@self, &Map.put(&1, :state, :listening))
  end

  def update_leader(node) do
    LeaderRegistry.update_leader(node)
  end

  def stop(pid) do
    Agent.stop(pid)
  end
end
