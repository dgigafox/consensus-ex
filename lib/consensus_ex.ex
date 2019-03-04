defmodule ConsensusEx do
  @moduledoc """
  ConsensusEx keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  alias ConsensusEx.Election

  @timeout 4_000

  def receive("PING") do
    "PONG"
  end

  def receive("ALIVE?") do
    # TODO: who_is_the_leader function
    # case do who_is_the_leader() do
    #   true -> "IAMTHEKING"
    #   false -> "FINETHANKS"
    # end
    IO.puts("FINETHANKS")
    "FINETHANKS"
  end

  def send_message(recipient, msg) do
    IO.inspect({recipient, msg}, label: "SENDING")
    IO.puts("SENDING MESSAGE")
    spawn_task(__MODULE__, :receive, recipient, [msg])
  end

  def spawn_task(module, fun, recipient, args) do
    recipient
    |> remote_supervisor()
    |> execute_async_task(module, fun, args)
    |> case do
      nil -> nil
      task -> Task.yield(task, @timeout * 4)
    end
    |> IO.inspect(label: "YIELD_RESP")
    |> evaluate_response(recipient, hd(args))
  end

  def broadcast(recipients, msg) when is_list(recipients) do
    recipients
    |> Enum.map(fn {k, _v} -> String.to_atom(Election.get_full_node_name(k)) end)
    |> Enum.map(&send_message(&1, msg))
  end

  defp evaluate_response(nil, _recipient, "ALIVE?"), do: IO.puts("START ELECTION")

  defp evaluate_response(nil, recipient, "PING") do
    Election.start_election(Node.self())
    send_message(recipient, "ALIVE?")
  end

  defp evaluate_response(resp, _, _), do: resp

  defp remote_supervisor(recipient) do
    {ConsensusEx.TaskSupervisor, recipient}
  end

  defp execute_async_task(sup, module, fun, args) do
    Task.Supervisor.async_nolink(sup, module, fun, args)
  catch
    :exit, _ -> nil
  end
end
