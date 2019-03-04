defmodule ConsensusEx.Election do
  @moduledoc false

  def get_connected_peers(hostname) do
    :net_adm.names(List.to_atom(hostname))
  end

  def who_is_the_leader?() do
    # get the highest ID among peers
  end
end
