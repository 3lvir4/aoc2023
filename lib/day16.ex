defmodule Day16 do
  alias Day10.Point

  def part_1(path) do
    File.stream!(path)
    |> parse()
    |> traversal({ {-1, 0}, {1, 0} })
  end

  def part_2(path) do
    File.stream!(path)
    |> parse()
    |> then(fn map -> 
      edge_starts(map)
      |> Enum.map(&traversal(map, &1))
      |> Enum.max()
    end)
  end

  defp edge_starts(map) do
    {max_x, max_y} = Map.keys(map)
    |> Enum.reduce({0, 0}, fn {x, y}, {max_x, max_y} ->
      { (if x > max_x, do: x, else: max_x), (if y > max_y, do: y, else: max_y) }
    end)

    [ 0..max_x |> Enum.flat_map(fn x -> [{ {x, -1}, {0, 1} }, { {x, max_y + 1}, {0, -1} }] end),
      0..max_y |> Enum.flat_map(fn y -> [{ {-1, y}, {1, 0} }, { {max_x + 1, y}, {-1, 0} }] end) ]
    |> Enum.concat()
  end

  # beam := {position, direction}
  defp traversal(map, start) do
    follow_beams(map, MapSet.new(), [start])
    |> Enum.map(&elem(&1, 0))
    |> Enum.uniq()
    |> Enum.count()
  end

  defp follow_beams(_, seen, []), do: seen

  defp follow_beams(map, seen, [curr | rest]) do
    {np, nd} = next = move(curr)
    
    {seen, rest} =
      case Map.get(map, np) do
        nil -> {seen, rest}
        
        c when c in ["\\", "/"] ->
          next = {np, reflect(nd, c)}
          if !MapSet.member?(seen, next), do: { MapSet.put(seen, next), [next | rest] }, else: {seen, rest}
        
        "|" when nd in [ {1, 0}, {-1, 0} ]->
          [ {np, {0, -1}}, {np, {0, 1}} ]
          |> Enum.reject(fn n -> MapSet.member?(seen, n) end)
          |> Enum.reduce({seen, rest}, fn n, {s, r} -> { MapSet.put(s, n), [n | r] } end)

        "-" when nd in [ {0, 1}, {0, -1} ]->
          [ {np, {1, 0}}, {np, {-1, 0}} ]
          |> Enum.reject(fn n -> MapSet.member?(seen, n) end)
          |> Enum.reduce({seen, rest}, fn n, {s, r} -> { MapSet.put(s, n), [n | r] } end)

        _ -> if !MapSet.member?(seen, next), do: { MapSet.put(seen, next), [next | rest] }, else: {seen, rest}
      end
    
    follow_beams(map, seen, rest)
  end

  defp move({p, d}), do: {move(p, d), d}
  defp move(p, d), do: Point.add(p, d)

  defp reflect({x, 0}, "\\"), do: {0, x}
  defp reflect({0, y}, "\\"), do: {y, 0}
  defp reflect({x, 0}, "/"), do: {0, -x}
  defp reflect({0, y}, "/"), do: {-y, 0}

  defp parse(f_stream) do
    f_stream
    |> Stream.map(&split_line/1)
    |> Stream.with_index()
    |> Enum.reduce(%{}, &parse_line/2)
  end

  defp parse_line({l, y}, contraption) do
    l
    |> Enum.with_index()
    |> Enum.reduce(contraption, fn {c, x}, map -> Map.put(map, {x, y}, c) end)
  end

  defp split_line(l), do: String.trim_trailing(l, "\n") |> String.split("", trim: true)
end

Path.expand("~/dev/advent_of_code/aoc2023/inputs/day16")
|> Day16.part_2()
|> IO.inspect(label: "result")
