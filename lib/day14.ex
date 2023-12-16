defmodule Day14 do
  alias Day10.Point

  @type platform() :: %{Point.t() => atom()}

  def part_1(path) do
     init_cache()
     File.stream!(path)
     |> parse()
     |> tilt(:n)
     |> then(fn plat -> {plat, max_y(plat)} end)
     |> total_load()
  end

  def part_2(path) do
    init_cache()
    File.stream!(path)
    |> parse()
    |> then(fn platform ->
      {i, last_seen, cycled} = find_repeat(platform)
      remaining = rem(1_000_000_000 - i, i - last_seen)
      total_load_cycles(cycled, remaining)
    end)
  end

  defp total_load_cycles(platform, n) do
    cycle(platform, n)
    |> (&total_load({&1, max_y(&1)})).()
  end

  defp find_repeat(original) do
    Stream.iterate(original, fn to_cycle -> cycle(to_cycle) end)
    |> Stream.with_index()
    |> Stream.drop(1)
    |> Enum.reduce_while(%{original => 0}, fn {cycled, i}, visited ->
      last_seen = Enum.find(visited, fn {pl, _} -> Map.equal?(pl, cycled) end) 
      if last_seen !== nil do
        {:halt, {i, elem(last_seen, 1), cycled}}
      else
        visited = Map.put(visited, cycled, i)
        {:cont, visited}
      end
    end)
  end

  defp init_cache() do
    :ets.new(:cache, [:set, :private, :named_table])
  end

  defp total_load({platform, max_y}) do
    platform
    |> Stream.filter(fn {_, c} -> c == :round end)
    |> Stream.map(fn {p, _} -> elem(p, 1) end)
    |> Stream.map(fn y -> (max_y + 1) - y end)
    |> Enum.sum()
  end

  defp cycle(platform, 0), do: platform
  defp cycle(platform , n), do: cycle(platform) |> cycle(n - 1)

  defp cycle(platform) do
    platform
    |> tilt(:n)
    |> tilt(:w)
    |> tilt(:s)
    |> tilt(:e)
  end

  defp tilt(platform, dir) do
    max_x = max_x(platform)
    max_y = max_y(platform)
    tilt(platform, max_x, max_y, dir)
  end

  defp tilt(platform, max_x, max_y, dir) when dir in [:n, :s] do
    (if dir == :n, do: 0..max_y, else: max_y..0//-1)
    |> Enum.reduce(platform, fn y, map ->
      for x <- 0..max_x, reduce: map do
        acc ->
          case Map.get(acc, {x, y}) do
            :round -> roll({x, y}, acc, dir)
            _ -> acc
          end
      end
    end)
  end

  defp tilt(platform, max_x, max_y, dir) when dir in [:e, :w] do
    (if dir == :w, do: 0..max_x, else: max_x..0//-1)
    |> Enum.reduce(platform, fn x, map ->
      for y <- 0..max_y, reduce: map do
        acc ->
          case Map.get(acc, {x, y}) do
            :round -> roll({x, y}, acc, dir)
            _ -> acc
          end
      end
    end)
  end

  defp roll({x, y}, map, dir, i \\ 1) do
    too_far = case dir do
      :n -> too_far?(x, y - i, map, :n)
      :w -> too_far?(x - i, y, map, :w)
      :s -> too_far?(x, y + i, map, :s)
      :e -> too_far?(x + i, y, map, :e)
    end

    if !too_far,
      do: roll({x, y}, map, dir, i + 1),
      else:
        (if i == 1 do
          map
        else
          map
          |> Map.replace!({x, y}, :empty)
          |> Map.replace!(offset_by({x, y}, i, dir), :round)
        end)
  end

  defp offset_by({x, y}, i, :n), do: {x, y - i + 1}
  defp offset_by({x, y}, i, :w), do: {x - i + 1, y}
  defp offset_by({x, y}, i, :s), do: {x, y + i - 1}
  defp offset_by({x, y}, i, :e), do: {x + i - 1, y}

  defp too_far?(_, y, _, :n) when y < 0, do: true
  defp too_far?(x, _, _, :w) when x < 0, do: true
  defp too_far?(x, y, map, dir) do
      case dir do
         :s -> y > max_y(map)
         :e -> x > max_x(map)
         _ -> false
      end
      |> Kernel.or(Map.get(map, {x, y}) != :empty)
  end    

  defp max_x(map) do
    case :ets.lookup(:cache, :max_x) do
      [{_, cached}] -> cached
      [] ->
        res = max_nth(map, 0)
        :ets.insert(:cache, {:max_x, res})
        res
    end
  end
  
  defp max_y(map) do
    case :ets.lookup(:cache, :max_y) do
      [{_, cached}] -> cached
      [] ->
        res = max_nth(map, 1)
        :ets.insert(:cache, {:max_y, res})
        res
    end
  end

  defp max_nth(map, n),
    do: map
      |> Map.keys()
      |> Enum.map(&elem(&1, n))
      |> Enum.max()

  @spec parse(File.Stream.t()) :: platform()
  defp parse(f_stream), do: Stream.with_index(f_stream) |> Enum.reduce(%{}, &parse_line_with_index/2)

  defp parse_line_with_index({l, y}, map) do
    for {c, x} <- parse_line(l), reduce: map do
      acc -> Map.put(acc, {x, y}, tile_to_atom(c))
    end
  end

  defp parse_line(l), do: l |> String.trim_trailing("\n") |> String.split("", trim: true) |> Enum.with_index()

  defp tile_to_atom("O"), do: :round
  defp tile_to_atom("#"), do: :cube
  defp tile_to_atom(_), do: :empty
end


Path.expand("~/dev/advent_of_code/aoc2023/inputs/day14")
|> Day14.part_2()
|> IO.inspect(label: "result")
