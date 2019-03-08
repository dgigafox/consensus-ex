defmodule ConsensusEx.ProcessRegistry do
  @moduledoc false

  import Process

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
end
