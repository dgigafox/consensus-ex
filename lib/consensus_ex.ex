defmodule ConsensusEx do
  @moduledoc """
  ConsensusEx keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  use GenServer

  def start_link(default) when is_list(default) do
    GenServer.start_link(__MODULE__, default)
  end

  def pop(pid) do
    GenServer.call(pid, :pop)
  end

  # Server

  def init(initial_param) do
    send(:"foo@iMac-2", {:pop, [:hi]})
    {:ok, initial_param}
  end

  def handle_call(:pop, from, [head | tail]) do
    IO.inspect(from)
    IO.inspect(head)
    IO.inspect(tail)
    {:reply, head, tail}
  end

  def handle_info(message, state) do
    IO.inspect(message)
    {:noreply, state}
  end
end
