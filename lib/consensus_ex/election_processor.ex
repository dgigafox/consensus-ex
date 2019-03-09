defmodule ConsensusEx.ElectionProcessor do
  use GenServer

  import ConsensusEx.Helpers.DistributedSystems

  alias ConsensusEx.Election
  alias ConsensusEx.Monitoring

  @self __MODULE__

  def start_link(node) do
    default = %{
      node: node,
      state: :stopped
    }

    GenServer.start_link(@self, default, name: @self)
  end

  def get_state(), do: GenServer.call(@self, :get_state)

  def init(default) do
    hostname = get_hostname(default.node)
    {:ok, peers} = get_connected_peers(hostname)

    case length(peers) do
      1 -> :ok
      _ -> send(self(), {:run_election, default.node})
    end

    {:ok, default}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state.state, state}
  end

  def handle_info({:run_election, node}, %{state: :stopped} = state) do
    Election.start_election(node)
    {:noreply, %{state | state: :running}}
  end

  def handle_info({:run_election, _node}, state) do
    {:noreply, state}
  end

  def handle_info({:stop_election, _node}, state) do
    {:noreply, %{state | state: :stopped}}
  end

  def handle_info({:restart_election?, node}, state) do
    send(@self, {:stop_election, node})

    case Monitoring.get_state() do
      :stopped -> send(@self, {:run_election, node})
      :running -> send(@self, {:stop_election, node})
    end

    {:noreply, state}
  end
end
