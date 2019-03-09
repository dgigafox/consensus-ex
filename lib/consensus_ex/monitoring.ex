defmodule ConsensusEx.Monitoring do
  use GenServer

  alias ConsensusEx.LeaderRegistry

  @self __MODULE__

  @timeout Application.get_env(:consensus_ex, :settings)[:timeout]
  @refresh_time @timeout

  @spec start_link(map()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(default) when is_map(default) do
    default = Map.merge(default, %{state: :stopped, timer_ref: nil})

    GenServer.start_link(__MODULE__, default, name: @self)
  end

  def get_state() do
    GenServer.call(@self, :get_state)
  end

  def run() do
    leader = LeaderRegistry.get_leader()
    send(@self, {:send_message, leader})
  end

  def stop() do
    GenServer.cast(@self, :stop)
  end

  def init(init_data) do
    {:ok, init_data}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state[:state], state}
  end

  def handle_info({:send_message, leader} = msg, state) do
    timer_ref = schedule_message(msg)

    ConsensusEx.send_message(leader, "PING", @timeout * 4)

    state = %{state | state: :running, timer_ref: timer_ref}
    {:noreply, state}
  end

  def handle_info({_ref, "FINETHANKS"}, state) do
    Process.exit(self(), :normal)
    {:noreply, state}
  end

  def handle_cast(:stop, state) do
    :timer.cancel(state.timer_ref)
    {:noreply, %{state | state: :stopped}}
  end

  defp schedule_message(msg) do
    Process.send_after(self(), msg, @refresh_time)
  end
end
