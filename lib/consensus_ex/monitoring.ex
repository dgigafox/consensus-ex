 defmodule ConsensusEx.Monitoring do
  use GenServer

  @self __MODULE__
  @refresh_time 4_000
  @recipient :"bar@consensus.ex"

  @spec start_link(map()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(default) when is_map(default) do
    GenServer.start_link(@self, default)
  end

  def get_peers() do
    GenServer.call(@self, {:get_peers})
  end

  # Server

  def init(init_data) do
    {:ok, hostname} = :inet.gethostname()
    :net_adm.names(List.to_atom(hostname)) |> IO.inspect(label: "NAMES")
    schedule_message()
    {:ok, init_data}
  end

  def handle_call({:get_peers}, _from, state) do
    # who_is_the_leader?(state)
    {:reply, state, state}
  end

  def handle_info(:send_message, state) do
    with {:ok, _} <- ConsensusEx.send_message(@recipient, "PING") do
      schedule_message()
    end

    {:noreply, state}
  end

  defp schedule_message do
    Process.send_after(self(), :send_message, @refresh_time)
  end
end
