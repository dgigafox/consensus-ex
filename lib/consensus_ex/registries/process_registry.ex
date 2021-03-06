defmodule ConsensusEx.ProcessRegistry do
  @moduledoc """
  Gives access to stored processes and actions to start or stop them.
  """

  import Process

  alias ConsensusEx.ElectionProcessor
  alias ConsensusEx.LeaderRegistry
  alias ConsensusEx.Monitoring

  @doc """
  Returns nil if process is dead and unregistered,
  returns pid if alive and registered
  """
  def get_pid(process_name) do
    whereis(process_name)
  end

  def stop_and_remove(process_name) do
    case get_pid(process_name) do
      nil -> :already_stopped
      pid -> send(pid, :kill)
    end
  end

  def direct_update_leader(leader) do
    LeaderRegistry.update_leader(leader)
  end

  def set_leader(node) do
    ElectionProcessor.set_leader(node)
  catch
    :exit, _ -> :already_exited
  end

  def start_election_process(node) do
    case Process.whereis(ElectionProcessor) do
      nil -> ElectionProcessor.start_link(node)
      _ -> send(ElectionProcessor, {:run_election, node})
    end
  end

  def start_monitoring_process(leader) do
    case Process.whereis(Monitoring) do
      nil -> Monitoring.start_link([])
      _ -> send(Monitoring, {:send_message, leader})
    end
  end
end
