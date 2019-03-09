defmodule ConsensusEx do
  @moduledoc """
  ConsensusEx keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  import ConsensusEx.Messenger
  import ConsensusEx.Helpers.DistributedSystems
  import ConsensusEx.ProcessRegistry

  alias ConsensusEx.ElectionProcessor
  alias ConsensusEx.Monitoring

  @timeout Application.get_env(:consensus_ex, :settings)[:timeout]
  @self __MODULE__

  def receive("PING") do
    "PONG"
  end

  def receive("ALIVE?") do
    Monitoring.stop()
    start_election_process(Node.self())
    "FINETHANKS"
  end

  def receive({leader, "IAMTHEKING", 1}) do
    Monitoring.stop()
    direct_update_leader(leader)
  end

  def receive({leader, "IAMTHEKING", _}) do
    IO.inspect(leader, label: "I RECEIVE IAMTHEKING")
    Monitoring.stop()

    set_leader(leader)
    |> IO.inspect(label: "SET_LEADER")
  end

  def send_message(recipient, msg, timeout \\ @timeout) do
    spawn_task(@self, :receive, recipient, [msg], timeout)
  end

  def broadcast_message(recipients, msg) when is_list(recipients) do
    recipients
    |> Enum.map(fn {k, _v} -> String.to_atom(get_full_node_name(k)) end)
    |> Enum.map(&send_message(&1, msg))
  end
end
