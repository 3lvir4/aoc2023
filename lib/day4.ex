defmodule Day4 do
  def part_1(path) do
    File.stream!(path)
    |> Enum.reduce(0, &sum_points/2)
  end
  
  @doc """
    schcard schema := {{winning, player}, copies}
  """
  def part_2(path) do
    File.stream!(path)
    |> Enum.map(fn l -> {parse_card(l), 1} end)
    |> proc_schcards(0)
  end

  defp proc_schcards([], total), do: total;
  
  defp proc_schcards([curr | rest], total) do 
    {{winning, player}, copies} = curr

    case length(winning -- (winning -- player)) do
      0 -> proc_schcards(rest, total + copies)
      n ->
        {copied, skip} = Enum.split(rest, n)
        rest = copied
        |> Enum.map(fn {b, c} -> {b, c + copies} end)
        |> Enum.concat(skip)
        proc_schcards(rest, total + copies)
    end
  end

  defp sum_points(l, acc) do
    {winning, player} = parse_card(l)
    winning -- (winning -- player)
    |> length()
    |> case do
      0 -> acc
      n -> acc + 2 ** (n-1)
    end
  end

  defp parse_card(l) do
    [_, data] = String.split(l, ": ")
    String.split(data, " | ")
    |> Enum.map(fn s -> 
      s
      |> String.split(" ")
      |> Enum.filter(fn n -> n != "" end)
      |> Enum.map(fn n -> String.trim(n) |> String.to_integer() end)
    end)
    |> List.to_tuple()
  end
end

Path.expand("~/dev/advent_of_code/aoc2023/inputs/day4")
|> Day4.part_2()
|> IO.puts()
