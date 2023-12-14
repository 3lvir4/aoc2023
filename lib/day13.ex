defmodule Day13 do
  import Bitwise

  def part_1(path), do: handle(path, 1)
  def part_2(path), do: handle(path, 0)    
  defp handle(path, offby), do: File.stream!(path) |> parse() |> summarize_all(offby)

  defp summarize_all(parsed_patterns, offby),
    do: parsed_patterns
      |> Stream.map(&summarize(&1, offby))
      |> Enum.sum()
  
  defp summarize({rows, cols}, offby) do
    rows_count = reflec_idx(rows, offby)
    if rows_count do
      100 * (rows_count + 1)
    else
      reflec_idx(cols, offby) + 1
    end
  end

  defp reflec_idx(tiles, offby),
    do:
      0..(tuple_size(tiles) - 2)
      |> Enum.find(fn i -> is_reflec?(tiles, i, i + 1, offby) end)

  defp is_reflec?(tiles, l, r, 0) when l < 0 or r >= tuple_size(tiles), do: true
  defp is_reflec?(tiles, l, r, _) when l < 0 or r >= tuple_size(tiles), do: false

  defp is_reflec?(tiles, l, r, offby) do
    diff = diff_count(elem(tiles, l), elem(tiles, r))
    is_reflec?(tiles, l - 1, r + 1, offby - diff) and offby - diff >= 0
  end

  defp diff_count(bl, br), do: bxor(bl, br) |> Integer.digits(2) |> Enum.count(&(&1 == 1))

  defp parse(f_stream) do
    f_stream
    |> Stream.chunk_while([], fn l, acc ->
      if l == "\n" do
        {:cont, Enum.reverse(acc), [l]}
      else
        {:cont, [l | acc]}
      end
    end, fn
      [] -> {:cont, []}
      acc -> {:cont, Enum.reverse(acc), []}
    end)
    |> Stream.map(&parse_pattern/1)
  end

  defp parse_pattern(pattern) when is_list(pattern) do
    clean_pattern = pattern
    |> Stream.map(fn l ->
      l
      |> String.trim_trailing("\n")
      |> String.split("")
      |> Enum.reject(&(&1 == ""))
    end)
    |> Stream.reject(&(&1 == []))

    nb_cols = length(hd(Enum.to_list(clean_pattern)))
    nb_rows = length(Enum.to_list(clean_pattern))

    clean_pattern
    |> Stream.with_index()
    |> Enum.reduce({Tuple.duplicate(0, nb_rows), Tuple.duplicate(0, nb_cols)}, fn {l, y}, {rows, cols} ->
      for {c, x} <- Enum.with_index(l), reduce: {rows, cols} do
        {a_rows, a_cols} ->
          if c == "#" do
            {
              put_elem(a_rows, y, elem(a_rows, y) + (1 <<< (x + 1))),
              put_elem(a_cols, x, elem(a_cols, x) + (1 <<< (y + 1)))
            }
          else
            {a_rows, a_cols}
          end
      end
    end)
  end
end

Path.expand("~/dev/advent_of_code/aoc2023/inputs/day13")
|> Day13.part_2()
|> IO.inspect(label: "result")
