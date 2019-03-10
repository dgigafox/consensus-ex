defmodule ConsensusEx.NodeRegistry do
  use Agent

  @self __MODULE__

  def start_link do
    Agent.start_link(
      fn ->
        %{id: :rand.uniform(10_000)}
      end,
      name: @self
    )
  end

  def get_info() do
    Agent.get(@self, & &1)
  end
end
