defmodule EctoHashids.Types do
  @moduledoc false

  # Schema names are here are for use as a human reference only; they may drift
  # due to refactoring or change to some completely different descriptive value.
  # These are just atoms, and won't raise an error if they don't actually exist.
  @prefix_descriptions Application.get_env(:ecto_hashids, :prefix_descriptions, %{
                         o: :ExampleModule
                       })

  @prefix_modules Map.new(@prefix_descriptions, fn {key, _schema} ->
                    prefix = Atom.to_string(key)
                    {prefix, Module.concat(__MODULE__, Macro.camelize(prefix))}
                  end)

  @prefix_separator Application.get_env(:ecto_hashids, :prefix_separator, "_")

  @characters Application.get_env(:ecto_hashids, :characters, "0123456789abcdefghjkmnpqrstvwxyz")

  @salt Application.get_env(:ecto_hashids, :salt, "")

  @min_length Application.get_env(:ecto_hashids, :min_len, 5)

  @after_compile __MODULE__

  def __after_compile__(_env, _bytecode) do
    Enum.each(@prefix_modules, &compile_prefix_module(&1, @prefix_separator))
  end

  @doc """
  Fetches the prefixed hashid module associated with the given prefix or hashid.
  """
  def fetch!(prefix_or_hashid) do
    prefix =
      case @prefix_separator do
        "" -> prefix_or_hashid |> String.slice(0..0)
        other -> prefix_or_hashid |> String.split(other, parts: 2) |> hd()
      end
      
    Map.fetch!(@prefix_modules, prefix)
  end

  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  defp compile_prefix_module({prefix, module}, separator) do
    prefixed_salt = prefix <> @salt

    contents =
      quote do
        @moduledoc false

        use Ecto.Type

        @codec Hashids.new(
                 alphabet: unquote(@characters),
                 min_len: unquote(@min_length),
                 salt: unquote(prefixed_salt)
               )

        # convenience function for encoding and decoding

        def prefix, do: unquote(prefix)

        def encode(token_ids) do
          unquote(prefix) <> unquote(separator) <> Hashids.encode(@codec, token_ids)
        end

        def decode("#{unquote(prefix)}#{unquote(separator)}" <> data) do
          case Hashids.decode(@codec, String.downcase(data)) do
            {:ok, [id]} ->
              {:ok, id}

            {:ok, _} ->
              :error

            {:error, _} ->
              :error
          end
        end

        def decode(int) do
          case Integer.parse(int) do
            {int, ""} ->
              {:ok, int}

            _ ->
              :error
          end
        end

        # type implementation

        @impl true
        def type, do: :integer

        @impl true
        def cast(hashid) when is_binary(hashid), do: {:ok, String.downcase(hashid)}
        def cast(_), do: :error

        @impl true
        def load(id) when is_integer(id) and id > 0, do: {:ok, encode(id)}
        def load(_), do: :error

        @impl true
        def dump(hashid), do: decode(hashid)
      end

    Module.create(module, contents, Macro.Env.location(__ENV__))

    module
  end
end
