defmodule Api.Helpers.MapHelper do
  @doc "
  Takes String keys in a Map and convers them to Atoms.
  "
  def string_keys_to_atoms(document) when is_map(document) do
    Enum.reduce(document, %{}, fn {key, val}, acc ->
      acc |> Map.put(
        cond do
          is_binary(key) -> String.to_atom(key)
          true -> key
        end, val)
    end)
  end
end
