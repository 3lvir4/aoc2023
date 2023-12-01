defmodule Day1 do
  def handle(data_path) do
    File.stream!(data_path)
    |> Enum.reduce(0, &proc_line/2)
  end

  defp proc_line(line, acc) do
    line
    |> String.to_charlist()
    |> Enum.filter(fn c -> c >= ?0 and c <= ?9 end)
    |> get_first_last_digit()
    |> case do
      {nil, nil} -> acc
      pair -> pair
          |> pair_to_2digit_num()
          |> Kernel.+(acc)
      end
  end

  defp pair_to_2digit_num({first, last}) do
    first
    |> Kernel.-(48)
    |> Kernel.*(10)
    |> Kernel.+(last - 48)
  end

  defp get_first_last_digit(cl), do: {List.first(cl), List.last(cl)}

end


path = Path.expand("~/dev/advent_of_code/aoc2023/inputs/day1")
IO.puts(Day1.handle(path))
