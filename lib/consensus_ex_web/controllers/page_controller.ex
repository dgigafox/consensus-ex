defmodule ConsensusExWeb.PageController do
  use ConsensusExWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
