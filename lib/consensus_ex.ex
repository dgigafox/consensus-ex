defmodule ConsensusEx do
  @moduledoc """
  ConsensusEx keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  # use GenServer

  # def start_link(default) when is_list(default) do
  #   GenServer.start_link(__MODULE__, default)
  # end

  # def pop(pid) do
  #   GenServer.call(pid, :pop)
  # end

  # # Server

  # def init(initial_param) do
  #   {:ok, initial_param}
  # end

  # def handle_call(:pop, from, [head | tail]) do
  #   IO.inspect(from)
  #   IO.inspect(head)
  #   IO.inspect(tail)
  #   {:reply, head, tail}
  # end

  # def handle_info(:work, state) do
  #   IO.inspect(state, label: "STATE")
  #   {:noreply, state}
  # end

  def receive_message(message) do
    IO.puts(message)
  end

  def send_message(recipient, message) do
    spawn_task(__MODULE__, :receive_message, recipient, [message])
  end

  def spawn_task(module, fun, recipient, args) do
    recipient
    |> remote_supervisor()
    |> Task.Supervisor.async(module, fun, args)
    |> Task.await()
  end

  defp remote_supervisor(recipient) do
    {ConsensusEx.TaskSupervisor, recipient}
  end
end
