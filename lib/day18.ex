defmodule Day18 do
  alias Day10.Point

  def part_1(path), do: File.stream!(path) |> Stream.map(&parse_line/1) |> solve()
  def part_2(path),
    do: File.stream!(path)
        |> Stream.map(fn l ->
          extract_components(l)
          |> List.last()
          |> String.slice(2..7)
          |> hex_to_instruct()
        end)
        |> solve()

  defp solve(instructions),
    do: instructions
      |> Enum.reduce_while({[{0, 0}], {0, 0}, 0}, &dig/2)
      |> then(fn {pts, perimeter} -> area(pts, perimeter) end)

  defp area(pts, perimeter), do: shoelace_area(pts) + div(perimeter, 2) + 1

  defp shoelace_area(pts) do
    pts
    |> Enum.chunk_every(3, 1, :discard)
    |> Enum.map(fn [p, c, n] ->
      elem(c, 1) * (elem(p, 0) - elem(n, 0))
    end)
    |> Enum.sum()
    |> abs()
    |> Kernel.div(2)
  end

  defp dig({dir, n}, {pts, pos, perimeter}) do
    next = Point.add(pos, Point.scamul(dir, n))
    if next == {0, 0} do
      pts = [pos | Enum.reverse([next | pts])]
      {:halt, {pts, perimeter + n}}
    else
      { :cont, {[next | pts], next, perimeter + n} }
    end
  end

  defp hex_to_instruct(hex), do: hex_to_instruct(hex, "")

  defp hex_to_instruct("", {d, n}), do: {dir(d), String.to_integer(n, 16)}

  defp hex_to_instruct("0", n), do: hex_to_instruct("", {"R", n})
  defp hex_to_instruct("1",  n), do: hex_to_instruct("", {"D", n})
  defp hex_to_instruct("2",  n), do: hex_to_instruct("", {"L", n})
  defp hex_to_instruct("3",  n), do: hex_to_instruct("", {"U", n})

  defp hex_to_instruct(<<c::binary-size(1), rest::binary>>, n), do: hex_to_instruct(rest, n <> c)
  
  defp parse_line(l), do: extract_components(l) |> to_dig_info()

  defp extract_components(l), do: String.trim_trailing(l, "\n") |>  String.split(" ", trim: true)

  defp to_dig_info([d, n, _]), do: {dir(d), String.to_integer(n)}

  defp dir("U"), do: {0, -1}
  defp dir("D"), do: {0, 1}
  defp dir("L"), do: {-1, 0}
  defp dir("R"), do: {1, 0}
end

Path.expand("~/dev/advent_of_code/aoc2023/inputs/day18")
|> Day18.part_2()
|> IO.inspect()
