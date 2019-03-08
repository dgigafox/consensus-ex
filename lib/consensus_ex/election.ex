defmodule ConsensusEx.Election do
  @moduledoc false

  import ConsensusEx.Helpers.DistributedSystems

  alias ConsensusEx.EventHandler
  alias ConsensusEx.ProcessRegistry

  @timeout 4_000

  def start_election(node) do
    IO.puts("STARTED_ELECTION")

    # send Alive to all higher id peers
    node
    |> get_higher_id_peers()
    |> case do
      [] -> broadcast_iamtheking(node)
      nodes -> multicast_alive(node, nodes)
    end
  end

  def multicast_alive(sending_node, receiving_nodes) when is_list(receiving_nodes) do
    receiving_nodes
    |> ConsensusEx.broadcast("ALIVE?")
    |> Enum.any?(&(&1 == {:ok, "FINETHANKS"}))
    |> case do
      false -> broadcast_iamtheking(sending_node)
      true -> wait_for_iamtheking()
    end
  end

  def wait_for_iamtheking do
    EventHandler.listen()
    pid = ProcessRegistry.get_pid(EventHandler)
    Process.send_after(pid, :unlisten, @timeout)
  end

  def broadcast_iamtheking(node) do
    {:ok, peers} = get_connected_peers(get_hostname(node))
    ConsensusEx.broadcast(peers, {node, "IAMTHEKING"})
  end
end
