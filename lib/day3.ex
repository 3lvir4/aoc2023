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

  defp part_numbers([curr | next], {results, prev}) do
    found = Regex.scan(~r/\d+/, curr, return: :index)
    |> Enum.filter(fn [{start, count}] -> 
      offset = count + min(0, start - 1)
      spectrum({prev, curr, next}, start, offset, count)
      |> Enum.any?(&symbol?/1)
    end)
    |> List.flatten()
    |> Enum.map(fn {start, count} -> String.slice(curr, start, count) |> String.to_integer() end)
    
    {results ++ found, curr}
  end

  def part_2(path) do
    File.stream!(path)
    |> Enum.map(&divide_and_conquer/1)
    |> Enum.chunk_every(2, 1)
    |> Enum.reduce({0, empty_bag()}, &sum_ratios/2)
    |> (fn {sum, _} -> sum end).()
  end

  defp sum_ratios([curr | tail], {sum, prev}) do
    next = Enum.at(tail, 0) || empty_bag()
    l_sum = curr
    |> Map.get(:gears)
    |> Enum.map(fn gear -> capture_tangent_part_nums(gear, {prev, curr, next}) end)
    |> Enum.filter(fn tangents -> length(tangents) == 2 end)
    |> Enum.map(fn [{_, n}, {_, m}] -> String.to_integer(n) * String.to_integer(m) end)
    |> List.flatten()
    |> Enum.sum()

    {sum + l_sum, curr}
  end

  defp capture_tangent_part_nums(gear, {prev, curr, next}) do
    Map.get(prev, :nums) ++ Map.get(curr, :nums) ++ Map.get(next, :nums)
    |> Enum.reject(&is_nil/1)
    |> Enum.filter(fn {pos, _} -> tangent?(gear, pos) end)
  end

  defp tangent?(gear, num) do
    {g_pos, _} = gear
    {start, count} = num
    start - 2 < g_pos && g_pos < start + count + 1
  end

  defp divide_and_conquer(l) do
    nums = 
      Regex.scan(~r/\d+/, l, return: :index)
      |> List.flatten()
      |> Enum.map(fn {start, count} -> { {start, count}, String.slice(l, start, count) } end)
    gears =
      Regex.scan(~r/\*/, l, return: :index)
      |> List.flatten()
    %{nums: nums, gears: gears}
  end

  defp empty_bag() do
    %{nums: [], gears: []}
  end

  defp spectrum({prev, curr, next}, start, offset, count) do
    [
      String.slice(prev, max(0, start - 1), offset + 2),
      String.slice(curr, start + count, 1),
      String.slice(Enum.at(next, 0) || "", max(0, start - 1), offset + 2),
      String.slice(curr, max(0, start - 1), 1 + min(0, start - 1))
    ]
  end
  
  defp symbol?(s) do
    nonsymbols = nonsymbols()
    String.graphemes(s)
    |> Enum.any?(fn c -> !Enum.member?(nonsymbols, c) end)
  end
end

Path.expand("~/dev/advent_of_code/aoc2023/inputs/day3")
|> Day3.part_2()
|> IO.puts()
