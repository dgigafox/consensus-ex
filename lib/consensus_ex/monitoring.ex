defmodule ConsensusEx.Monitoring do
  use GenServer

  @self __MODULE__
  @refresh_time 4_000
  @recipient :"bar@consensus.ex"
  @timeout 4_000

  @spec start_link(map()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(default) when is_map(default) do
    default = Map.put(default, :leader, @recipient)
    GenServer.start_link(__MODULE__, default, name: @self)
  end

  def get_leader() do
    GenServer.call(@self, {:get_leader})
  end

  def update_leader(node) do
    GenServer.cast(@self, {:update, node})
    |> IO.inspect(label: "CAST_RESP")
  end

  # Server

  def init(init_data) do
    {:ok, hostname} = :inet.gethostname()
    :net_adm.names(List.to_atom(hostname)) |> IO.inspect(label: "NAMES")
    schedule_message()
    {:ok, init_data}
  end

  def handle_call({:get_leader}, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:update, node}, state) do
    state = %{state | leader: node}
    IO.inspect(state, label: "NEW_STATE")
    {:noreply, state}
  end

  def handle_info(:send_message, state) do
    # schedule_message()
    response = ConsensusEx.send_message(state.leader, "PING", @timeout * 4)

    with {:ok, "PONG"} <- response do
      schedule_message()
    end

    {:noreply, state}
  end

  def handle_info({_ref, "FINETHANKS"}, state) do
    Process.exit(self(), :normal)
    {:noreply, state}
  end

  defp schedule_message do
    Process.send_after(self(), :send_message, @refresh_time)
  end
end
