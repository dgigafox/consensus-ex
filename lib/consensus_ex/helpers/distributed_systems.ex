defmodule ConsensusEx.Helpers.DistributedSystems do
  @moduledoc """
  Helpers for any distributed system-related functions
  """

  def get_full_node_name(name) do
    hostname =
      get_hostname(Node.self())
      |> Atom.to_string()

    name = List.to_string(name)

    name <> "@" <> hostname
  end

  def get_connected_peers(hostname) do
    :net_adm.names(hostname)
  end

  def get_hostname(node) do
    node
    |> Atom.to_string()
    |> String.split("@")
    |> List.last()
    |> String.to_atom()
  end

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
    |> IO.inspect(label: "HIGHER_IDS")
  end
end
