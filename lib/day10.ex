defmodule Day10 do
  defmodule Point do
    @type t() :: {integer(), integer()}
    defguardp is_point(x, y) when is_integer(x) and is_integer(y) 

    @spec add(t(), t()) :: t()
    def add({x1, y1}, {x2, y2}) when is_point(x1, y1) and is_point(x2, y2) do
      {x1 + x2, y1 + y2}
    end

    @spec sub(t(), t()) :: t()
    def sub({x1, y1}, {x2, y2}) when is_point(x1, y1) and is_point(x2, y2) do
      {x1 - x2, y1 - y2}
    end

    @spec manhattan_distance(t(), t()) :: pos_integer()
    def manhattan_distance({x1, y1}, {x2, y2})
    when is_point(x1, y1) and is_point(x2, y2) do
      abs(x2 - x1) + abs(y2 - y1)    
    end

    @spec equal?(t(), t()) :: boolean()
    def equal?({x1, y1}, {x2, y2}) when is_point(x1, y1) and is_point(x2, y2) do
      x1 == x2 and y1 == y2
    end
  end

  @type grid() :: %{Point.t() => binary()}

  def part_1(path) do
    File.stream!(path)
    |> parse()
    |> then(fn {start, next, grid} -> find_loop(next, start, grid, 0) end)
  end

  def part_2(path) do
    File.stream!(path)
    |> parse()
    |> then(fn {start, next, grid} ->
      {grid, loop_points} = collect_loop_points(next, start, grid, MapSet.new([start, next]))
      prev = loop_points |> Enum.find(fn p -> p != next and Point.manhattan_distance(p, start) == 1 end)
      
      ch_start = char_of_start(prev, start, next)
      {normalize_points(grid, loop_points, ch_start), grid}
    end)
    |> sum_inside_loop_points()
  end

  defp sum_inside_loop_points({grid, loop_points}) do
    max_x = Map.keys(grid) |> Enum.map(&elem(&1, 0)) |> Enum.max()
    max_y = Map.keys(grid) |> Enum.map(&elem(&1, 1)) |> Enum.max()

    0..max_y
    |> Enum.reduce(MapSet.new(), fn y, outside_set ->
      0..max_x
      |> Enum.reduce({false, false, outside_set}, fn x, {inside, pipeup, acc} ->
        {inside, pipeup} = case Map.get(grid, {x, y}) do
          "|" -> {!inside, pipeup}
          c when c in ["L", "F"] -> {inside, c == "L"}
          c when c in ["7", "J"]
            -> if c != (if pipeup, do: "J", else: "7") do
              {!inside, !pipeup}
            else
              {inside, pipeup}
            end
          _ -> {inside, pipeup}
        end
        if inside do
          {inside, pipeup, acc}
        else
          {inside, pipeup, MapSet.put(acc, {x, y})}
        end
      end)
      |> elem(2)
    end)
    |> MapSet.union(loop_points)
    |> then(fn not_enclosed ->
      Enum.count(grid) - Enum.count(not_enclosed)
    end)
  end

  @spec normalize_points(grid(), MapSet.t(Point.t()), binary()) :: grid()
  defp normalize_points(grid, loop_points, ch_start) do
    grid
    |> Enum.map(fn {point, c} ->
      case c do
        "S" -> {point, ch_start}
        _ ->
          if point in loop_points do
            {point, c}
          else
            {point, "."}
          end
      end
   end)
    |> Map.new()
  end

  @spec char_of_start(Point.t(), Point.t(), Point.t()) :: binary()
  defp char_of_start(prev, start, next) do
    dirs = %{{0, -1} => :n, {-1, 0} => :e, {0, 1} => :s, {1, 0} => :w}
    
    dir_next = Map.get(dirs, Point.sub(start, next))

    case Map.get(dirs, Point.sub(start, prev)) do
      :n ->
        case dir_next do
          :e -> "L"
          :s -> "|"
          :w -> "J"
        end
      :e ->
        case dir_next do
          :s -> "F"
          :w -> "-"
          :n -> "L"
        end
      :s ->
        case dir_next do
          :w -> "7"
          :n -> "|"
          :e -> "F"
        end
      :w ->
        case dir_next do
          :n -> "J"
          :e -> "-"
          :s -> "7"
        end
    end
  end

  @spec find_loop(Point.t(), Point.t(), grid(), integer()) :: integer()
  defp find_loop(curr, prev, grid, len) do
    curr_tile = Map.get(grid, curr)
    if curr_tile == "S" do
      div(len + 1, 2)
    else
      next = directions(curr_tile)
      |> Enum.find(fn d -> d != Point.sub(prev, curr) end)
      
      find_loop(Point.add(curr, next), curr, grid, len + 1)
    end
  end

  @spec collect_loop_points(Point.t(), Point.t(), grid(), MapSet.t(Point.t())) :: {grid(), MapSet.t(Point.t())}
  defp collect_loop_points(curr, prev, grid, loop_set) do
    curr_tile = Map.get(grid, curr)
    if curr_tile == "S" do
      {grid, loop_set}
    else
      next = directions(curr_tile)
      |> Enum.find(fn d -> d != Point.sub(prev, curr) end)
      
      collect_loop_points(Point.add(curr, next), curr, grid, MapSet.put(loop_set, Point.add(curr, next)))
    end 
  end

  @spec parse(File.Stream.t()) :: {Point.t(), Point.t(), grid()} 
  defp parse(lines) do
    grid = lines
    |> Stream.with_index()
    |> Stream.flat_map(fn {l, i} -> l
      |> String.trim_trailing("\n")
      |> String.graphemes()
      |> Stream.with_index()
      |> Stream.map(fn {c, j} -> {{j, i}, c} end)    
    end)
    |> Map.new()
    
    {start, _} = Enum.find(grid, fn {_, c} -> c == "S" end)
    surrounding_start = [n: {0, -1}, e: {1, 0}, s: {0, 1}, w: {-1, 0}]
    
    way_to_go = surrounding_start
    |> Enum.map(fn {d, offset} ->
      Point.add(start, offset)
      |> then(fn p -> Map.get(grid, p) end)
      |> then(fn tile -> {d, directions(tile)} end)
    end)
    |> Enum.find(fn {dir_from_start, tile_dirs} ->
      case dir_from_start do
        :n -> Enum.any?(tile_dirs, &(&1 == {0, 1}))
        :e -> Enum.any?(tile_dirs, &(&1 == {-1, 0}))
        :s -> Enum.any?(tile_dirs, &(&1 == {0, -1}))
        :w -> Enum.any?(tile_dirs, &(&1 == {1, 0}))
      end
    end)
    |> elem(0)
    |> then(fn d -> Keyword.get(surrounding_start, d) end)

    {start, Point.add(start, way_to_go), grid}
  end

  @spec directions(binary()) :: [Point.t()]
  defp directions("|"), do: [{0, -1}, {0, 1}]
  defp directions("-"), do: [{-1, 0}, {1, 0}]
  defp directions("L"), do: [{0, -1}, {1, 0}]
  defp directions("J"), do: [{0, -1}, {-1, 0}]
  defp directions("7"), do: [{0, 1}, {-1, 0}]
  defp directions("F"), do: [{0, 1}, {1, 0}]
  defp directions(_), do: [{0, 0}]
end

Path.expand("~/dev/advent_of_code/aoc2023/inputs/day10")
|> Day10.part_2()
|> IO.inspect(label: "result")
