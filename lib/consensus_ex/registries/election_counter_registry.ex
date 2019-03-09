defmodule ConsensusEx.ElectionCounterRegistry do
  use Agent

  @self __MODULE__

  def start_link do
    Agent.start_link(fn -> 0 end, name: @self)
  end

  def get() do
    Agent.get(@self, & &1)
  end

  def increment() do
    Agent.update(@self, &(&1 + 1))
  end
end
