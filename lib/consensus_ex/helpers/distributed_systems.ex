defmodule ConsensusEx.Helpers.DistributedSystems do
  @moduledoc """
  Helpers for distributed system-related functions
  """

  alias ConsensusEx.NodeRegistry

  @doc """
  Gets the full node name in string

  iex> ConsensusEx.Helpers.DistributedSystems.get_full_node_name('darren')
  "darren@consensus.ex"
  """
  def get_full_node_name(name) do
    hostname =
      Node.self()
      |> get_hostname()
      |> Atom.to_string()

    name = List.to_string(name)

    name <> "@" <> hostname
  end

  @doc """
  Gets connected peers including self and corresponding IDs by fetching
  information through rpc call.

  iex> ConsensusEx.Helpers.DistributedSystems.get_connected_peers(hostname)
  {:ok, [{'darren', 2134}, {'meadow', 3244}, {'shaye', 8818}, {'foo', 7149}, {'bar', 7899}]}
  """
  def get_connected_peers(hostname) do
    peers =
      hostname
      |> :net_adm.names()
      |> elem(1)
      |> Enum.map(&get_full_node_name_atom(&1))
      |> Enum.map(&rpc_call(&1, NodeRegistry.get_info()))

    {:ok, peers}
  end

  @doc """
  Gets the hostname of the node

  iex> ConsensusEx.Helpers.DistributedSystems.get_hostname(Node.self())
  :"consensus.ex"
  """
  def get_hostname(node) do
    node
    |> Atom.to_string()
    |> String.split("@")
    |> List.last()
    |> String.to_atom()
  end

  @doc """
  Gets the peers with higher IDs than the current node

  iex> ConsensusEx.Helpers.DistributedSystems.get_higher_id_peers(Node.self())
  [{'meadow', 3244}, {'shaye', 8818}, {'foo', 7149}, {'bar', 7899}]
  """
  def get_higher_id_peers(node) do
    {:ok, peers} = get_connected_peers(get_hostname(node))

    name =
      node
      |> Atom.to_string()
      |> String.split("@")
      |> hd()
      |> String.to_charlist()

    {_, id} = List.keyfind(peers, name, 0)

    Enum.filter(peers, fn {_k, v} -> v > id end)
  end

  defp get_full_node_name_atom({name, _}) do
    name
    |> get_full_node_name()
    |> String.to_atom()
  end

  defp rpc_call(node, %{} = state) do
    case :rpc.call(node, NodeRegistry, :get_info, []) do
      {:badrpc, {:EXIT, {:calling_self, _}}} ->
        {name_to_charlist(node), state.id}

      remote_state ->
        {name_to_charlist(node), remote_state.id}
    end
  end

  defp name_to_charlist(node) do
    node
    |> Atom.to_string()
    |> String.split("@")
    |> hd()
    |> String.to_charlist()
  end
end
