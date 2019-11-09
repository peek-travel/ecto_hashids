defmodule EctoHashids do
  @moduledoc """
  Seamlessly interact w/ sequential IDs via their Hashid equivalent.
  """

  alias EctoHashids.Types

  @doc """
  Given an unambiguous representation of an id, generate other supported
  representations of that id. Ensures that the hashid and prefix are valid.

  ## Examples

      iex> EctoHashids.id!({"o", 10})
      %{hashid: "o_gqmgq", pkey: 10, prefix: "o"}

      iex> EctoHashids.id!("o_5zabk")
      %{hashid: "o_5zabk", pkey: 6418, prefix: "o"}

      iex> EctoHashids.id!("O_Z7EXY")
      %{hashid: "o_z7exy", pkey: 206586, prefix: "o"}
  """
  def id!({prefix, pkey}) when is_binary(prefix) and is_integer(pkey) do
    serializer = Types.fetch!(prefix)
    normalized = serializer.encode(pkey)

    %{
      pkey: pkey,
      hashid: normalized,
      prefix: serializer.prefix()
    }
  end

  def id!(hashid) when is_binary(hashid) do
    normalized = String.downcase(hashid)
    serializer = Types.fetch!(normalized)
    {:ok, pkey} = serializer.decode(normalized)

    %{
      pkey: pkey,
      hashid: normalized,
      prefix: serializer.prefix()
    }
  end
end
