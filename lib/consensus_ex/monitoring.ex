defmodule ConsensusEx.Monitoring do
  use GenServer

  alias ConsensusEx.LeaderRegistry

  @self __MODULE__
  @refresh_time 4_000
  # @recipient :"bar@consensus.ex"
  @timeout 4_000

  @spec start_link(map()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(default) when is_map(default) do
    default = Map.merge(default, %{state: :stopped, timer_ref: nil})
    GenServer.start_link(__MODULE__, default, name: @self)
  end

  def get_state() do
    GenServer.call(@self, :get_state)
  end

  def run() do
    send(@self, :send_message)
  end

  def stop() do
    send(@self, :stop)
  end

  # Server

  def init(init_data) do
    {:ok, init_data}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state[:state], state}
  end

  def handle_info(:send_message, state) do
    timer_ref = schedule_message()

    leader = LeaderRegistry.get_leader()
    ConsensusEx.send_message(leader, "PING", @timeout * 4)

    state = %{state | state: :running, timer_ref: timer_ref}
    IO.inspect(state, label: "STATE")
    {:noreply, state}
  end

  def handle_info({_ref, "FINETHANKS"}, state) do
    Process.exit(self(), :normal)
    {:noreply, state}
  end

  def handle_info(:stop, state) do
    :timer.cancel(state.timer_ref)
    {:stop, :normal, %{state | state: :stopped}}
  end

  defp schedule_message do
    Process.send_after(self(), :send_message, @refresh_time)
  end
end
