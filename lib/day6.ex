defmodule Day6 do
  def part_1(path) do
    File.stream!(path)
    |> parse_input()
    |> Enum.reduce(1, fn {t, d}, mul -> mul * num_of_ways(t, d) end) 
  end

  def part_2(path) do
    File.stream!(path)
    |> then(fn input -> 
      [times, distances] = Enum.map(input, &parse_line/1)
      {concat_int_list(times), concat_int_list(distances)}
    end)
    |> then(fn {t, d} -> num_of_ways(t, d) end)
  end
  
  defp num_of_ways(t, d) do
    fsqd = :math.sqrt(Integer.pow(t, 2) - 4 * d)
    sqd = trunc(fsqd)
    round_square? = sqd == fsqd
    
    {inf, sup} = if round_square? do
      {div(t - sqd + 1, 2) + 1, div(t + sqd, 2) - 1}
    else
      {div(t - sqd + 1, 2), div(t + sqd, 2)}
    end

    Range.size(inf..sup)
  end

  defp concat_int_list(list),
    do: list
    |> Enum.map(&Integer.to_string/1)
    |> Enum.join()
    |> String.to_integer()
  
  defp parse_input(input) do
    [times, distances] = Enum.map(input, &parse_line/1)
    Enum.zip(times, distances)
  end

  defp parse_line("Time: " <> times), do: String.split(times) |> Enum.map(&String.to_integer/1)
  defp parse_line("Distance: " <> distances), do: String.split(distances) |> Enum.map(&String.to_integer/1)
end

Path.expand("~/dev/advent_of_code/aoc2023/inputs/day6")
|> Day6.part_2()
|> IO.puts()
