defmodule ConsensusEx.ElectionProcessor do
  use GenServer

  import ConsensusEx.Helpers.DistributedSystems

  alias ConsensusEx.Election
  alias ConsensusEx.ElectionCounterRegistry
  alias ConsensusEx.LeaderRegistry
  alias ConsensusEx.Monitoring

  @self __MODULE__

  def start_link(node) do
    GenServer.start_link(@self, node, name: @self)
  end

  def get_state(), do: GenServer.call(@self, :get_state)

  def set_leader(node), do: GenServer.call(@self, {:receive_iamtheking, node})

  def init(node) do
    state = %{node: node}

    hostname = get_hostname(state.node)
    {:ok, peers} = get_connected_peers(hostname)

    case length(peers) do
      1 -> :ok
      _ -> send(@self, {:run_election, state.node})
    end

    {:ok, state}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state.state, state}
  end

  def handle_call({:receive_iamtheking, leader}, _from, state) do
    IO.inspect(leader, label: "CAST LEADER")
    LeaderRegistry.update_leader(leader)
    {:noreply, state, state}
  end

  def handle_info({:run_election, node}, state) do
    ElectionCounterRegistry.increment()
    count = ElectionCounterRegistry.get()
    Election.start_election(node, count)
    {:noreply, state}
  end

  def handle_info({:restart_election?, node}, state) do
    send(@self, {:stop_election, node})

    case Monitoring.get_state() do
      :stopped -> send(@self, {:run_election, node})
      :running -> send(@self, {:stop_election, node})
    end

    {:noreply, state}
  end

  def handle_info({:stop_election, _node}, state) do
    {:stop, :normal, state}
  end
end
