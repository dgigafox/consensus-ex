defmodule ConsensusEx do
  @moduledoc """
  ConsensusEx keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def receive("PING") do
    IO.puts("PONG")
  end

  def ping(recipient) do
    IO.puts("SENDING PING...")
    spawn_task(__MODULE__, :receive, recipient, ["PING"])
  end

  def spawn_task(module, fun, recipient, args) do
    recipient
    |> remote_supervisor()
    |> Task.Supervisor.async_nolink(module, fun, args)
    |> IO.inspect(label: "TASK")
    |> Task.yield(4_000)
  end

  defp remote_supervisor(recipient) do
    {ConsensusEx.TaskSupervisor, recipient}
  end
end
