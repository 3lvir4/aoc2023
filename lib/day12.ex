defmodule Day12 do
  def part_1(path) do
    File.stream!(path)
    |> Stream.map(&parse_line/1)
    |> Stream.map(&nb_of_arrangements/1)
    |> Enum.sum()
  end

  def part_2(path) do
    File.stream!(path)
    |> Stream.map(&parse_line_unfold/1)
    |> Stream.map(&nb_of_arrangements/1)
    |> Enum.sum()
  end

  defp nb_of_arrangements({record, sizes}) do
    :ets.new(:cache, [:set, :private, :named_table])
    res = nb_of_arrangements(record, sizes, 0, 0)
    :ets.delete(:cache)
    res
  end

  defp nb_of_arrangements(record, sizes, pos, group_i)
    when group_i >= length(sizes),
      do:
        (if pos < length(record) and "#" in Enum.slice(record, pos..-1//1) do
          0
        else
          1
        end)

  defp nb_of_arrangements(record, _, pos, _) when pos >= length(record), do: 0

  defp nb_of_arrangements(record, sizes, pos, group_i) do
    g_size = Enum.at(sizes, group_i)

    result = case :ets.lookup(:cache, {pos, group_i}) do
      [{_, cached}] -> {:fromcache, cached}
      [] -> res = case Enum.at(record, pos) do
        "." -> nb_of_arrangements(record, sizes, pos + 1, group_i)
        "#" ->
          if "." in Enum.slice(record, pos..(pos + g_size - 1)) or Enum.at(record, pos + g_size) == "#" do
            0
          else
            nb_of_arrangements(record, sizes, pos + g_size + 1, group_i + 1)
          end
        "?" ->
          if "." in Enum.slice(record, pos..(pos + g_size - 1)) or Enum.at(record, pos + g_size) == "#" do
            nb_of_arrangements(record, sizes, pos + 1, group_i)
          else
            nb_of_arrangements(record, sizes, pos + g_size + 1, group_i + 1) +
            nb_of_arrangements(record, sizes, pos + 1, group_i)
          end
        end
        {:new, res}
    end

    case result do
      {:fromcache, val} -> val
      {:new, val} ->
        :ets.insert(:cache, {{pos, group_i}, val})
        val
    end
  end

  defp parse_line(l) do
    [record, sizes] = String.trim_trailing(l, "\n") |> String.split(" ")
    sizes = String.split(sizes, ",") |> Enum.map(&String.to_integer/1)
    record = String.graphemes(record <> ".")

    {record, sizes}
  end

  defp parse_line_unfold(l) do
    [record, sizes] = String.trim_trailing(l, "\n") |> String.split(" ")
    sizes = String.split(sizes, ",")
    |> Enum.map(&String.to_integer/1)
    |> List.duplicate(5) |> Enum.concat()
  
    record = [record]
    |> List.duplicate(5)
    |> Enum.concat()
    |> Enum.join("?")
    |> Kernel.<>(".")
    |> String.graphemes()

    {record, sizes}
  end
end

Path.expand("~/dev/advent_of_code/aoc2023/inputs/day12")
|> Day12.part_2()
|> IO.inspect(label: "result")
