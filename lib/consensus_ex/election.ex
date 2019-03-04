defmodule ConsensusEx.Election do
  @moduledoc false

  def start_election(node) do
    # send Alive to all higher id peers
    node
    |> get_higher_id_peers()
    |> ConsensusEx.broadcast("ALIVE?")
    |> Enum.any?(& {:ok, "FINETHANKS"} = &1)
    |> IO.inspect(label: "BROADCAST_RESP")
  end

  # to be transferred to helpers
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

  def who_is_the_leader?() do
    # get the highest ID among peers
  end
end
