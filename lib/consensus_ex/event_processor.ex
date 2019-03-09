defmodule ConsensusEx.EventProcessor do
  use GenServer

  alias ConsensusEx.ElectionProcessor
  alias ConsensusEx.LeaderRegistry
  alias ConsensusEx.Monitoring

  @self __MODULE__

  def start_link(default) when is_map(default) do
    default = Map.put(default, :listening, true)
    GenServer.start_link(@self, default, name: @self)
  end

  def get_state() do
    GenServer.call(@self, :get_state)
  end

  def listen() do
    GenServer.cast(@self, :listen)
  end

  def unlisten() do
    GenServer.cast(@self, :unlisten)
  end

  def receive({:receive, _node} = message) do
    GenServer.cast(@self, message)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_cast({:receive, node}, state) do
    LeaderRegistry.update_leader(node)
    Monitoring.run()

    {:noreply, state}
  end

  def handle_cast(:listen, state) do
    {:noreply, %{state | listening: true}}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state.listening, state}
  end

  def handle_info(:unlisten, state) do
    case Monitoring.get_state() do
      :running -> :ok
      :stopped -> send(ElectionProcessor, {:run_election, Node.self()})
    end

    {:noreply, %{state | listening: false}}
  end

  def handle_info(:kill, state) do
    {:stop, :normal, state}
  end
end
