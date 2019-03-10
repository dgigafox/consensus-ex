defmodule ConsensusEx do
  @moduledoc """
  ConsensusEx is an Elixir implementation of a distributed system of nodes
  that agrees upon a single leader at any point in time
  """
  import ConsensusEx.Messenger
  import ConsensusEx.Helpers.DistributedSystems
  import ConsensusEx.ProcessRegistry

  alias ConsensusEx.ElectionProcessor
  alias ConsensusEx.Monitoring

  @timeout Application.get_env(:consensus_ex, :settings)[:timeout]
  @self __MODULE__

  @doc """
  Matches the message PING and returns PONG
  """
  def receive("PING") do
    "PONG"
  end

  @doc """
  Matches the message ALIVE?, starts the election the same time after sending FINETHANKS
  """
  def receive("ALIVE?") do
    Monitoring.stop()

    case Process.whereis(ElectionProcessor) do
      nil -> start_election_process(Node.self())
      _ -> send(ElectionProcessor, {:run_election, Node.self()})
    end

    "FINETHANKS"
  end

  @doc """
  Matches the message IAMTHEKING with the given args:
  receive({leader node, message, initialized election id})
  then updates the leader and monitors it
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

  @doc """
  Sends a message to a recipient with given timeout (T)
  """
  def send_message(recipient, msg, timeout \\ @timeout) do
    spawn_task(@self, :receive, recipient, [msg], timeout)
  end

  @doc """
  Broadcasts message to multiple recipients
  """
  def broadcast_message(recipients, msg) when is_list(recipients) do
    recipients
    |> Enum.map(fn {k, _v} -> String.to_atom(get_full_node_name(k)) end)
    |> Enum.map(&send_message(&1, msg))
  end
end
