defmodule Day11 do
  alias Day10.Point, as: Point

  def part_1(path) do
    File.stream!(path)
    |> parse()
    |> sum_shortest_paths()
  end

  def part_2(path) do
    File.stream!(path)
    |> parse(1_000_000)
    |> sum_shortest_paths()
  end

  defp sum_shortest_paths(g_points) do
    g_points
    |> possible_pairs()
    |> Enum.reduce(0, fn {a, b}, acc ->
      if Point.equals(a, b) do
        acc
      else
        acc + Point.manhattan_distance(a, b)
      end
    end)
  end

  @spec possible_pairs(Enumerable.t(Point.t())) :: MapSet.t({Point.t(), Point.t()})
  defp possible_pairs(points),
    do:
      Enum.reduce(points, MapSet.new(), fn p, pairs ->
        Enum.reduce(points, pairs, fn q, acc ->
          if {q, p} in acc do
            acc
          else  
            MapSet.put(acc, {p, q})
          end
        end)
      end)

  @spec parse(File.Stream.t(), pos_integer()) :: Enumerable.t(Point.t())
  defp parse(f_stream, growth_factor \\ 2) do
    lines = f_stream
    |> Stream.map(fn l ->
      String.trim_trailing(l, "\n")
      |> String.split("", trim: true)
      |> Enum.with_index()
    end)
    |> Stream.with_index()

    {empty_ys, empty_xs} = Enum.reduce(lines, {[], []},
      fn {l, i}, {empty_ys, galaxies_xs} ->
        empty_ys = if !Enum.any?(l, &(elem(&1, 0) == "#")) do
          [i | empty_ys]
        else
          empty_ys
        end
        
        new_galaxies_xs = Enum.filter(l, &(elem(&1, 0) == "#"))
        |> Enum.reduce(galaxies_xs, fn y, acc -> [y | acc] end)

        {empty_ys, new_galaxies_xs}
    end)
    |> then(fn {eys, galaxies_xs} ->
      max_x = Enum.count(Enum.at(lines, 1) |> elem(0)) - 1
      empty_xs = Enum.filter(0..max_x, fn x ->
        x not in Enum.map(galaxies_xs, &elem(&1, 1))
      end)
      
      {eys, empty_xs}
    end)

    lines
    |> Stream.flat_map(fn {l, y} ->
      if y in empty_ys do
        []
      else
        offset_y = Enum.count(empty_ys, fn yv -> yv < y end)
      
        l
        |> Stream.filter(&(elem(&1, 0) == "#"))
        |> Stream.map(fn {_, x} ->
          offset_x = Enum.count(empty_xs, fn xv -> xv < x end)
          {x + offset_x * (growth_factor - 1), y + offset_y * (growth_factor - 1)}
        end)
      end
    end)
  end
end

Path.expand("~/dev/advent_of_code/aoc2023/inputs/day11")
|> Day11.part_2()
|> IO.inspect()
