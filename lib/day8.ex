defmodule Day8 do
  def part_1(path) do
    File.stream!(path)
    |> Enum.map(&String.trim/1)
    |> parse()
    |> count_steps("AAA", &(&1 == "ZZZ"))
  end

  def part_2(path) do
    File.stream!(path)
    |> Enum.map(&String.trim/1)
    |> parse()
    |> then(fn bag ->
      ghosts_starting_blocks = Map.keys(elem(bag, 1)) |> Enum.filter(&String.ends_with?(&1, "A"))
      stops_on_Z = &String.ends_with?(&1, "Z")

      for start <- ghosts_starting_blocks, reduce: 1 do
        acc -> ppcm(acc, count_steps(bag, start, stops_on_Z))
      end
    end)
  end

  def ppcm(a, b) do
    max = max(a, b)
    min = min(a, b)

    Stream.iterate(max, &(&1 + max))
    |> Enum.find(fn n -> rem(n, min) == 0 end)
  end

  defp count_steps({directions, nodes}, start, end_predicate) do
    directions
    |> Enum.reduce_while({0, start}, fn d, {count, curr_idx} ->
      if end_predicate.(curr_idx) do
        {:halt, count}
      else
        d_idx = Enum.find_index(["L", "R"], &(&1 == d))
        next_idx = Map.get(nodes, curr_idx) |> Enum.at(d_idx)
        {:cont, {count + 1, next_idx}}
      end
    end)
  end

  defp parse([directions | network]), do: {parse_directions(directions), parse_network(network)}
  
  defp parse_directions(directions), do: String.graphemes(directions) |> Stream.cycle()
  defp parse_network(network) do
    for line <- network, into: %{} do
      {
        String.slice(line, 0, 3),
        [String.slice(line, 7, 3), String.slice(line, 12, 3)]
      }
    end
  end
end

Path.expand("~/dev/advent_of_code/aoc2023/inputs/day8")
|> Day8.part_2()
|> IO.inspect(label: "result")
