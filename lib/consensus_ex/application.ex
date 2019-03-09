defmodule ConsensusEx.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the endpoint when the application starts
      supervisor(ConsensusExWeb.Endpoint, []),
      # Start your own worker by calling: ConsensusEx.Worker.start_link(arg1, arg2, arg3)
      # worker(ConsensusEx.Worker, [arg1, arg2, arg3]),
      # {ConsensusEx.Monitoring, %{}},
      {Task.Supervisor, name: ConsensusEx.TaskSupervisor},
      worker(ConsensusEx.LeaderRegistry, []),
      worker(ConsensusEx.ElectionCounterRegistry, []),
      worker(ConsensusEx.ElectionProcessor, [Node.self()], restart: :transient),
      worker(ConsensusEx.Monitoring, [%{}])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ConsensusEx.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ConsensusExWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
