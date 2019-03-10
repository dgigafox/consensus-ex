defmodule ConsensusEx.Election do
  @moduledoc """
  Election related functions that defines the election procedure
  """

  import ConsensusEx.Helpers.DistributedSystems

  alias ConsensusEx.ElectionProcessor
  alias ConsensusEx.ProcessRegistry

  @timeout Application.get_env(:consensus_ex, :settings)[:timeout]

  @doc """
  Starts the election by sending ALIVE? to peers with higher IDs
  """
  def start_election(node, initialized_election_count) do
    node
    |> get_higher_id_peers()
    |> multicast_alive(node, initialized_election_count)
  end

  @doc """
  Multicasts (sends to multiple known nodes) ALIVE?
  If it receives FINETHANKS, it wait for the message IAMTHEKING
  but if it did not, it broadcasts IAMTHEKING to all connected nodes
  """
  def multicast_alive(receiving_nodes, sending_node, count) when is_list(receiving_nodes) do
    receiving_nodes
    |> ConsensusEx.broadcast_message("ALIVE?")
    |> Enum.any?(&(&1 == {:ok, "FINETHANKS"}))
    |> case do
      false -> broadcast_iamtheking(sending_node, count)
      true -> wait_for_iamtheking(sending_node)
    end
  end

  @doc """
  Waits for the IAMTHEKING message and verifies if election needs
  to be restarted or not
  """
  def wait_for_iamtheking(node) do
    pid = ProcessRegistry.get_pid(ElectionProcessor)
    Process.send_after(pid, {:restart_election?, node}, @timeout)
  end

  @doc """
  Stops the election process and broadcast IAMTHEKING message
  """
  def broadcast_iamtheking(node, count) do
    {:ok, peers} = get_connected_peers(get_hostname(node))
    ConsensusEx.broadcast_message(peers, {node, "IAMTHEKING", count})
    send(ElectionProcessor, {:stop_election, node})
  end
end
