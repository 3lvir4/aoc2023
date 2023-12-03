defmodule Day3 do
  defp nonsymbols() do
    ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ".", "\n"]
  end

  def part_1(path) do
    File.stream!(path)
    |> Enum.chunk_every(2, 1)
    |> Enum.reduce({[], ""}, &part_numbers/2)
    |> (fn {results, _} -> Enum.sum(results) end).()
  end

  def part_numbers([curr, next], {results, prev}) do
    found = Regex.scan(~r/\d+/, curr, return: :index)
    |> Enum.filter(fn [{start, count}] -> 
      offset = count + min(0, start - 1)
      spectrum({prev, curr, next}, start, offset, count)
      |> Enum.any?(&has_symbol?/1)
    end)
    |> List.flatten()
    |> Enum.map(fn {start, count} -> String.slice(curr, start, count) |> String.to_integer() end)
    
    {results ++ found, curr}
  end

  defp spectrum({prev, curr, next}, start, offset, count) do
    [
      String.slice(prev, max(0, start - 1), offset + 2),
      String.slice(curr, start + count, 1),
      String.slice(Enum.at(next, 0) || "", max(0, start - 1), offset + 2),
      String.slice(curr, max(0, start - 1), 1 + min(0, start - 1))
    ]
  end
  
  defp has_symbol?(s) do
    nonsymbols = nonsymbols()
    String.graphemes(s)
    |> Enum.any?(fn c -> !Enum.member?(nonsymbols, c) end)
  end
end

Path.expand("~/dev/advent_of_code/aoc2023/inputs/day3")
|> Day3.part_1()
|> IO.puts()
