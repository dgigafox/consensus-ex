defmodule ConsensusEx.Election do
  @moduledoc """
  Election related functions that defines the election procedure
  """

  import ConsensusEx.Helpers.DistributedSystems

  alias ConsensusEx.ElectionProcessor
  alias ConsensusEx.ProcessRegistry

  @timeout Application.get_env(:consensus_ex, :settings)[:timeout]

  def start_election(node, initialized_election_count) do
    node
    |> get_higher_id_peers()
    |> multicast_alive(node, initialized_election_count)
  end

  def multicast_alive(receiving_nodes, sending_node, count) when is_list(receiving_nodes) do
    receiving_nodes
    |> ConsensusEx.broadcast_message("ALIVE?")
    |> Enum.any?(&(&1 == {:ok, "FINETHANKS"}))
    |> case do
      false -> broadcast_iamtheking(sending_node, count)
      true -> wait_for_iamtheking(sending_node)
    end
  end

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
