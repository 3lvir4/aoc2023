defmodule Day1 do
  defp str_digit_map() do
   %{
      one: 1,
      two: 2,
      three: 3,
      four: 4,
      five: 5,
      six: 6,
      seven: 7,
      eight: 8,
      nine: 9
    }  
  end

  def handle(data_path) do
    File.stream!(data_path)
    |> Enum.filter(&String.trim(&1) != "")
    |> Enum.reduce(0, &proc_line/2)
  end

  defp proc_line(line, acc) do
    res = 0..String.length(line)-1
    |> Enum.map(fn i -> extract_digits(line, i) end)
    |> Enum.filter(fn d -> d !== nil end)
    case { List.first(res), List.last(res) } do
      {nil, _} -> acc
      {_, nil} -> acc
      {f, l} -> acc + concat_two_dgts(f, l)
    end
  end

  def extract_digits(str, i \\ 0) do
    case String.at(str, i) do
      nil -> nil
      c ->
        case Integer.parse(c) do
          {c, ""} -> c
          _ ->
            match_str_to_dgt(String.slice(str, i..-1))
        end
    end
  end

  defp concat_two_dgts(a, b) do
    tmp = Integer.to_string(a) <> Integer.to_string(b)
    String.to_integer(tmp)
  end
  
  def match_str_to_dgt(str) do
    map = str_digit_map()
    Map.keys(map)
    |> Enum.find(fn sdgt -> String.starts_with?(str, Atom.to_string(sdgt)) end)
    |> (fn sdgt -> Map.get(map, sdgt) end).()
  end
end


path = Path.expand("~/dev/advent_of_code/aoc2023/inputs/day1")
IO.puts(Day1.handle(path))
