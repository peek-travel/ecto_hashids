# EctoHashids

### IDs are hard.

Ecto, out of the box, works really well with sequential ids. But then, you release your fancy new service and your users see a url like `/purchases/4` and the illusion that you have any sort of traction is gone.

### How do others solve this?

Some solve this w/ UUIDs, meaning your users instead see `/purchase/051c022e-8b9d-4d32-991d-58ad00a92d59` and that might suit you very well, but there are some annoyances that come up w/ UUIDs
  - they are really ugly
  - it isn't "memorable" (think "here's your confirmation number")
  - they take up a more space in the DB
  - ecto, out of the box, assumes sequential ids so you have to do some (easy) customization

### What does this library do about it?

EctoHashids is essentially an Ecto Type generator where you configure which schemas you want to expose hashids instead of sequential ids, and w/ 1 line in your schema, you can now interact w/ that model w/ the hashid instead of the sequential id.

In the above example, your user could now see: `/purchases/o_5zabk`

### IMPORTANT:

Some folks (rightly) want to avoid sequential ids for __security reasons__
I.e if I am shown `/purchases/1`, I could just change the `1` to a `2` and see information about some other purchase.

This library __DOESN'T HELP__ w/ the above security hole. A user can just as easily guess a random hashid (since they are short and wonderful) as they can a sequential id.

Any solution to solving the security hole to sequential ids can and should be added onto of these Hashids if it's devastating for a user to find their way to a url you were expecting. (ex: `/purchases/o_5zabk/some-token-for-this-id`)

## Installation

The package can be installed by adding `ecto_hashids` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ecto_hashids, "~> 0.0.1"}
  ]
end
```

### Configuration
The very minimal configuration you'll need is to define which schemas you want to generate these types for. Let's say you have a single Schema called `Purchase` and hou want to have `p_abc123`-looking hashids, you can do this in two steps:

```elixir
config :ecto_hashids,
  prefix_descriptions: %{
    p: Purchase
  }
```
This will auto-generate a module for you: `EctoHashids.Types.P`.

 All you have to do is use that as your primary key inside your `Purchase` schema:

```elixir
@primary_key {:id, EctoHashids.Types.P, read_after_writes: true}
````

If you have any relationships that `belong_to :purchase`, you'll need to tell ecto how to handle that as well:
```elixir
belongs_to :purchase, Purchase, type: EctoHashids.Types.P
```

And you're done!

### Recommended Configuration:
```elixir
config :ecto_hashids,
  prefix_separator: "_",                         # What goes after the prefix?
  characters: "0123456789abcdefghjkmnpqrstvwxyz", # Which characters should be valid for hashid
  salt: "fef02203-0e9c-45d4-89f2-f2ac7d154f36",  # What do you want to use for a salt for creating hashids
  prefix_descriptions: %{
    p: Purchase,                                 # Include all of your modules
  }
```

### Final thoughts

The only annoyance that can come w/ hashids is that you don't see them when looking inside the DB via a db-client of some sort. This means in your logs you'll see, oh user "u_abc123" is doing something bad. You want to quickly find out which actual user ID that is in your DB and you are a bit stuck. This library has some utility functions to help you:

```elixir
# Will dump the primary key
EctoHashids.id!("u_abc123")

# Inversely, this will encode the sequential id for you
EctoHashids.id!({"u", 10})
```

Putting it all together:
```elixir
%{hashid: hashid, pkey: 10, prefix: "p"} = EctoHashids.id!({"p", 10})

%Purchase{id: hashid} = Repo.get(Purchase, hashid)
```

The docs can be found at [https://hexdocs.pm/ecto_hashids](https://hexdocs.pm/ecto_hashids).

