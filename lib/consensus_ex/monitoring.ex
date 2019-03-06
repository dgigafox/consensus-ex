defmodule ConsensusEx.Monitoring do
  use GenServer

  @self __MODULE__
  @refresh_time 4_000
  # @recipient :"bar@consensus.ex"
  @timeout 4_000

  @spec start_link(map()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(default) when is_map(default) do
    # default = Map.put(default, :leader, nil)
    GenServer.start_link(__MODULE__, default, name: @self)
  end

  # Server

  def init(init_data) do
    {:ok, hostname} = :inet.gethostname()
    :net_adm.names(List.to_atom(hostname)) |> IO.inspect(label: "NAMES")
    schedule_message()
    {:ok, init_data}
  end

  def handle_info(:send_message, state) do
    schedule_message()
    ConsensusEx.send_message(state.leader, "PING", @timeout * 4)

    {:noreply, state}
  end

  def handle_info({_ref, "FINETHANKS"}, state) do
    Process.exit(self(), :normal)
    {:noreply, state}
  end

  def handle_info(:kill, state) do
    {:stop, :normal, state}
  end

  defp schedule_message do
    Process.send_after(self(), :send_message, @refresh_time)
  end
end
