defmodule ConsensusEx do
  @moduledoc """
  ConsensusEx keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  alias ConsensusEx.Election
  alias ConsensusEx.Monitoring

  @timeout 4_000

  def receive("PING") do
    "PONG"
  end

  def receive("ALIVE?") do
    Election.start_election(Node.self())
    "FINETHANKS"
  end

  def receive({node, "IAMTHEKING"}) do
    Monitoring.update_leader(node)
    IO.inspect(node, label: "IAMTHEKING_NODE")
  end

  def send_message(recipient, msg, timeout \\ @timeout) do
    IO.inspect({recipient, msg}, label: "SENDING")
    IO.puts("SENDING MESSAGE")
    spawn_task(__MODULE__, :receive, recipient, [msg], timeout)
  end

  def spawn_task(module, fun, recipient, args, timeout) do
    recipient
    |> remote_supervisor()
    |> execute_async_task(module, fun, args)
    |> case do
      nil -> nil
      task -> Task.yield(task, timeout)
    end
    |> IO.inspect(label: "YIELD_RESP")
    |> evaluate_response(recipient, hd(args))
  end

  def broadcast(recipients, msg) when is_list(recipients) do
    recipients
    |> Enum.map(fn {k, _v} -> String.to_atom(Election.get_full_node_name(k)) end)
    |> Enum.map(&send_message(&1, msg))
  end

  defp evaluate_response(nil, _recipient, "ALIVE?"), do: nil

  defp evaluate_response(nil, _recipient, "PING") do
    Election.start_election(Node.self())
    IO.puts("START_ELECTION")
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
