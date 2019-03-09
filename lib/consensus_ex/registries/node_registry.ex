defmodule ConsensusEx.NodeRegistry do
  use GenServer

  import ConsensusEx.Helpers.DistributedSystems

  @self __MODULE__

  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: @self)
  end

  def get_info() do
    GenServer.call(@self, :get_info)
  end

  def get_peers(hostname) do
    GenServer.call(@self, {:get_peers, hostname})
  end

  def init(_default) do
    state = %{
      id: :rand.uniform(10_000),
      peers: []
    }

    {:ok, state}
  end

  def handle_call(:get_info, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:get_peers, hostname}, _from, state) do
    peers =
      hostname
      |> :net_adm.names()
      |> elem(1)
      |> Enum.map(&get_full_node_name_atom(&1))
      |> Enum.map(&rpc_call(&1, state))

    {:noreply, peers, %{state | peers: peers}}
  end

  defp get_full_node_name_atom({name, _}) do
    name
    |> get_full_node_name()
    |> String.to_atom()
  end

  defp rpc_call(node, %{} = state) do
    IO.inspect(node, label: "NODES")

    case :rpc.call(node, @self, :get_info, []) do
      {:badrpc, {:EXIT, {:calling_self, _}}} ->
        {name_to_charlist(node), state.id}

      remote_state ->
        {name_to_charlist(node), remote_state.id}
    end
    |> IO.inspect(label: "RPC CALL")
  end

  defp name_to_charlist(node) do
    node
    |> Atom.to_string()
    |> String.split("@")
    |> hd()
    |> String.to_charlist()
  end
end
