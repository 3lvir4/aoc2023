defmodule Day2 do
  defp limit_data() do
    %{red: 12, green: 13, blue: 14}
  end

  def part_1(path) do
    File.stream!(path)
    |> Enum.reduce(0, &proc_record/2)
  end

  defp proc_record(l, acc) do
    {id, sets} = id_data_pair(l)
    impossible = sets
    |> Enum.any?(fn set -> is_impossible_set(set) end)
    if impossible do
      acc
    else
      acc + id
    end
  end

  defp is_impossible_set(set) do
    limits = limit_data()
    set
    |> Enum.reduce(%{red: 0, green: 0, blue: 0}, &get_counts/2)
    |> Enum.any?(fn {clr, count} -> count > Map.get(limits, clr) end)
  end

  defp get_counts({count, color}, acc) do
    Map.update!(acc, String.to_atom(color), fn prv -> prv + String.to_integer(count) end)
  end

  defp id_data_pair(l) do
    [game, rv_str] = String.split(l, ": ")
    [_, game_id] = String.split(game, " ")
    
    sets = rv_str
    |> String.split("; ")
    |> Enum.map(fn set -> String.split(set, ", ") end)
    |> Enum.map(fn set -> Enum.map(set, fn s -> String.split(s) |> List.to_tuple end) end)
    {String.to_integer(game_id), sets}
  end
end


Path.expand("~/dev/advent_of_code/aoc2023/inputs/day2")
|> Day2.part_1()
|> IO.puts()
