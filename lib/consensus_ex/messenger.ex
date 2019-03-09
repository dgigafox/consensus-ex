defmodule ConsensusEx.Messenger do
  @moduledoc """
  Messaging processes and response handlers
  """

  import ConsensusEx.ProcessRegistry

  alias ConsensusEx.Election
  alias ConsensusEx.Monitoring
  alias ConsensusEx.ElectionProcessor

  def spawn_task(module, fun, recipient, args, timeout) do
    recipient
    |> remote_supervisor()
    |> execute_async_task(module, fun, args)
    |> case do
      nil -> nil
      task -> Task.yield(task, timeout)
    end
    |> handle_response(recipient, hd(args))
  end

  defp handle_response({:exit, _}, recipient, msg) do
    handle_response(nil, recipient, msg)
  end

  defp handle_response(nil, _recipient, "ALIVE?"), do: nil

  defp handle_response(nil, _recipient, "PING") do
    Monitoring.stop()
    start_election_process(Node.self())
  end

  defp handle_response(resp, _, _), do: resp

  defp remote_supervisor(recipient) do
    {ConsensusEx.TaskSupervisor, recipient}
  end

  defp execute_async_task(sup, module, fun, args) do
    Task.Supervisor.async_nolink(sup, module, fun, args)
  catch
    :exit, _ -> nil
  end
end
