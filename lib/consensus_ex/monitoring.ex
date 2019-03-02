 defmodule ConsensusEx.Monitoring do
  use GenServer

  @self __MODULE__
  @refresh_time 4_000

  def start_link(default) when is_list(default) do
    GenServer.start_link(@self, default)
  end

  # Server

  def init(init_data) do
    schedule_refresh()
    {:ok, init_data}
  end

  def handle_info(:refresh, state) do
    schedule_refresh()
    ConsensusEx.ping(:"bar@retinas-MacBook-Pro")
    {:noreply, state}
  end

  defp schedule_refresh do
    Process.send_after(self(), :refresh, @refresh_time)
  end
 end
