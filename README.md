# ConsensusEx

ConsensusEx is an Elixir implementation of a distributed system of nodes
that agrees upon a single leader at any point in time.

## Development

- Install [asdf](https://github.com/asdf-vm/asdf) version manager
- Install Erlang and Elixir

```
asdf plugin-add erlang https://github.com/asdf-vm/asdf-erlang
asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir

asdf install
```

- Install hex, rebar, phoenix and mix dependencies

```
mix local.hex --force
mix local.rebar --force
mix archive.install --force https://github.com/phoenixframework/archives/raw/master/phx_new.ez
mix deps.get
```

## How to Run

Before running any node, you must first input your hostname in the `etc/hosts`
of your machine that will serve as your DNS.

For example:
```
##
# Host Database
#
# localhost is used to configure the loopback interface
# when the system is booting.  Do not change this entry.
##
127.0.0.1       localhost
255.255.255.255 broadcasthost
::1             localhost
127.0.0.1       consensus.ex  #add this line
```

where consensus.ex is your chosen hostname.

Now we can start our participating nodes. In the directory of the source code,
run a node using `name` flag. Let us run 3 nodes for example.

```elixir
$ iex --name darren@consensus.ex -S mix

$ iex --name shaye@consensus.ex -S mix

$ iex --name meadow@consensus.ex -S mix
```

No need to run any command to join the cluster as they will automatically join
as long as they have the same hostnames.

Now we can ask each of them who is their leaders. By typing the following
command on each node:

```elixir
iex(darren@consensus.ex)> ConsensusEx.LeaderRegistry.get_leader()
:"shaye@consensus.ex"

iex(meadow@consensus.ex)> ConsensusEx.LeaderRegistry.get_leader()
:"shaye@consensus.ex"

iex(shaye@consensus.ex)4> ConsensusEx.LeaderRegistry.get_leader()
:"shaye@consensus.ex"
```

To get the names of the nodes and their corresponding IDs you may type this command
in any of the nodes

```elixir
iex> alias ConsensusEx.Helpers.DistributedSystems
ConsensusEx.Helpers.DistributedSystems
iex> hostname = DistributedSystems.get_hostname(Node.self())
:"consensus.ex"
iex> DistributedSystems.get_connected_peers(hostname)
{:ok, [{'darren', 4839}, {'meadow', 5146}, {'shaye', 9138}]}
```

By trying to stop the iex process of the leader, we can see that the other nodes will
try to elect another leader

```elixir
iex(shaye@consensus.ex)3>
BREAK: (a)bort (c)ontinue (p)roc info (i)nfo (l)oaded
       (v)ersion (k)ill (D)b-tables (d)istribution
^C⏎

iex(darren@consensus.ex)5> ConsensusEx.LeaderRegistry.get_leader()
:"meadow@consensus.ex"

iex(meadow@consensus.ex)3> ConsensusEx.LeaderRegistry.get_leader()
:"meadow@consensus.ex"
```

That's it! You may try to create 2 or more nodes and see the transition
of leadership on each nodes.

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
# consensus-ex
