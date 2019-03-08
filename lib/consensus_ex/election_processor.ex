defmodule ConsensusEx.ElectionProcessor do
  use GenServer

  import ConsensusEx.Helpers.DistributedSystems

  alias ConsensusEx.Election

  @self __MODULE__

  def start_link(node) do
    GenServer.start_link(@self, node, name: @self)
  end

  def init(node) do
    hostname = get_hostname(node)
    {:ok, peers} = get_connected_peers(hostname)

    case length(peers) do
      1 -> :ok
      _ -> send(self(), {:run_election, node})
    end

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
