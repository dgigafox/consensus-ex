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
    ElectionProcessor.start_link(node)
  catch
    :exit, _ -> :error
  end

  def start_monitoring_process() do
    Monitoring.start_link([])
  catch
    :exit, _ -> :error
  end
end
