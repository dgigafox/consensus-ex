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

    case Process.whereis(ElectionProcessor) do
      nil -> start_election_process(Node.self())
      _ -> send(ElectionProcessor, {:run_election, Node.self()})
    end

    "FINETHANKS"
  end

  @doc """
  receive({leader node, message, initialized election id})
  """
  def receive({leader, "IAMTHEKING", 1}) do
    Monitoring.stop()
    direct_update_leader(leader)
    start_monitoring_process()
  end

  def receive({leader, "IAMTHEKING", _}) do
    Monitoring.stop()
    set_leader(leader)
    start_monitoring_process()
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
