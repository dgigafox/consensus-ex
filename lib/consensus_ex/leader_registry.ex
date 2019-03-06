defmodule ConsensusEx.LeaderRegistry do
  use Agent

  @self __MODULE__

  def start_link do
    Agent.start_link(fn -> %{leader: nil} end, name: @self)
  end

  def get_leader() do
    Agent.get(@self, &Map.get(&1, :leader))
  end

  def update_leader(leader) do
    Agent.update(@self, &Map.put(&1, :leader, leader))
  end
end
