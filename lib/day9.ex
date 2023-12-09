defmodule Day9 do
  def part_1(path) do
    File.stream!(path)
    |> Stream.map(&parse_line/1)
    |> Stream.map(&next_value(&1, [List.last(&1)]))
    |> Enum.sum()
  end

  def part_2(path) do
    File.stream!(path)
    |> Stream.map(&parse_line/1)
    |> Stream.map(&prev_value(&1, [hd(&1)]))
    |> Enum.sum()
  end

  defp next_value(seq, lasts) do
    diffs = compute_diffs(seq)

    [last_diff | _] = diffs
    all_same? = Enum.all?(diffs, &(&1 == last_diff))
    
    if all_same?,
      do: Enum.sum([last_diff | lasts]),
      else: next_value(Enum.reverse(diffs), [last_diff | lasts])
  end

  defp prev_value(seq, firsts) do
    diffs = compute_diffs(seq) |> Enum.reverse()

    [first_diff | _] = diffs
    all_same? = Enum.all?(diffs, &(&1 == first_diff))

    if all_same?,
      do: calc_prev_val([first_diff | firsts]),
      else: prev_value(diffs, [first_diff | firsts])
  end

  defp compute_diffs(seq),
    do: seq
      |> Enum.reduce({[], nil}, fn curr, {acc, prev} ->
        case prev do
          nil -> {acc, curr}
          _ -> { [curr - prev | acc], curr}
        end
      end)
      |> elem(0)

  defp calc_prev_val(firsts),
    do: firsts
      |> Enum.reverse()
      |> Enum.with_index()
      |> then(fn [{hd, _} | tl] ->
        Enum.reduce(tl, hd, fn {n, i}, acc ->
          if rem(i, 2) == 0,
            do: acc + n,
            else: acc - n
        end)
      end)

  defp parse_line(l),
    do:
      l
      |> String.split(" ")
      |> Enum.map(fn n -> String.trim_trailing(n, "\n") |> String.to_integer() end)
end

Path.expand("~/dev/advent_of_code/aoc2023/inputs/day9")
|> Day9.part_2()
|> IO.inspect(label: "result")
