defmodule ConsensusEx do
  @moduledoc """
  ConsensusEx keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  import ConsensusEx.Messenger
  import ConsensusEx.Helpers.DistributedSystems

  alias ConsensusEx.ElectionProcessor
  alias ConsensusEx.EventProcessor
  alias ConsensusEx.Monitoring

  @timeout Application.get_env(:consensus_ex, :settings)[:timeout]
  @self __MODULE__

  def receive("PING") do
    "PONG"
  end

  def receive("ALIVE?") do
    Monitoring.stop()
    send(ElectionProcessor, {:run_election, Node.self()})
    "FINETHANKS"
  end

  def receive({leader, "IAMTHEKING"}) do
    Monitoring.stop()
    EventProcessor.receive({:receive, leader})
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
