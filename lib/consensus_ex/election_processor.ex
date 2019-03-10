defmodule ConsensusEx.ElectionProcessor do
  use GenServer

  import ConsensusEx.Helpers.DistributedSystems

  alias ConsensusEx.Election
  alias ConsensusEx.ElectionCounterRegistry
  alias ConsensusEx.LeaderRegistry

  @self __MODULE__

  def start_link(node) do
    GenServer.start_link(@self, node, name: @self)
  end

  def get_state(), do: GenServer.call(@self, :get_state)

  def set_leader(node), do: GenServer.cast(@self, {:receive_iamtheking, node})

  def init(node) do
    state = %{node: node}

    hostname = get_hostname(state.node)
    {:ok, peers} = :net_adm.names(hostname)

    case length(peers) do
      1 -> :ok
      _ -> send(@self, {:run_election, state.node})
    end

    {:ok, state}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:receive_iamtheking, leader}, state) do
    LeaderRegistry.update_leader(leader)
    {:noreply, state}
  end

  @doc """
  Run election:
  1. Get election count initialized
  2. Erase leader
  3. Start election
  """
  def handle_info({:run_election, node}, state) do
    ElectionCounterRegistry.increment()
    count = ElectionCounterRegistry.get()

    LeaderRegistry.update_leader(nil)

    Election.start_election(node, count)
    {:noreply, state}
  end

  def handle_info({:restart_election?, node}, state) do
    send(@self, {:stop_election, node})

    case LeaderRegistry.get_leader() do
      nil -> send(@self, {:run_election, node})
      _ -> send(@self, {:stop_election, node})
    end

    {:noreply, state}
  end

  def handle_info({:stop_election, _node}, state) do
    {:stop, :normal, state}
  end
end
