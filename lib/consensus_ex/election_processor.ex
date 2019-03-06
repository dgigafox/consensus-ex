defmodule ConsensusEx.ElectionProcessor do
  use GenServer

  alias ConsensusEx.Election

  @self __MODULE__

  def start_link(node) do
    GenServer.start_link(@self, node, name: @self)
  end

  def init(node) do
    send(self(), {:run_election, node})
    {:ok, node}
  end

  def handle_info({:run_election, node}, state) do
    Election.start_election(node)
    {:noreply, state}
  end

  def handle_info(:kill, state) do
    {:stop, :normal, state}
  end
end
