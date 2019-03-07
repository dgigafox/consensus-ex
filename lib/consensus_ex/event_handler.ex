defmodule ConsensusEx.EventHandler do
  use GenServer

  alias ConsensusEx.LeaderRegistry
  alias ConsensusEx.Monitoring

  @self __MODULE__

  # def start_link do
  #   Agent.start_link(fn -> %{state: nil} end, name: @self)
  # end

  # def switch_state do
  #   Agent.update(@self, &Map.put(&1, :state, :listening))
  # end

  # def update_leader(node) do
  #   LeaderRegistry.update_leader(node)
  # end

  # def stop(pid) do
  #   Agent.stop(pid)
  # end

  def start_link(default) when is_map(default) do
    default = Map.put(default, :listening, false)
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

  def handle_cast({:receive, node}, %{listening: true} = state) do
    LeaderRegistry.update_leader(node)
    Monitoring.run()
    {:noreply, %{state | listening: false}}
  end

  def handle_cast({:receive, _node}, state) do
    {:noreply, state}
  end

  def handle_cast(:listen, state) do
    {:noreply, %{state | listening: true}}
  end

  def handle_cast(:unlisten, state) do
    {:noreply, %{state | listening: false}}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state.listening, state}
  end

  def handle_info(:kill, state) do
    {:stop, :normal, state}
  end

  def handle_info(:unlisten, state) do
    {:noreply, %{state | listening: false}}
  end
end
