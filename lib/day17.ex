defmodule Day17 do
  alias Day10.Point

  defmodule PQueue do
    @type t() :: Heap.t({priority(), value()})
    @type priority() :: integer()
    @type value() :: any()

    def new(), do: Heap.min()
    def new({_priority, _value} = elem), do: [elem] |> Enum.into(Heap.min())
    def new(elems), do: elems |> Enum.into(Heap.min())

    @spec pop_min!(t()) :: {{priority(), value()}, t()}
    def pop_min!(q), do: min(q)

    defp min([]), do: raise "empty"
    defp min(q) do
      min = q |> Heap.root()
      {min, Heap.pop(q)}
    end

    def empty?(q), do: Heap.empty?(q)

    def member?(q, {_priority, _value} = elem), do: Enum.member?(q, elem)
    def member?(q, value), do: Enum.any?(q, fn {_, val} -> val == value end)

    @spec push(t(), priority(), value()) :: t()
    @spec push(t(), {priority(), value()}) :: t()
    def push(q, priority, value), do: push(q, {priority, value})
    def push(q, {_priority, _value} = elem), do: Heap.push(q, elem)

    def size(q), do: Heap.size(q)
  end

  def part_1(path), do: solve(path, 1, 3)
  def part_2(path), do: solve(path, 4, 10)

  defp solve(path, min_seq_cont, max_seq_cont) do
    :ets.new(:day17, [:set, :private, :named_table])
    :ets.insert(:day17, {:min_seq_cont, min_seq_cont})
    :ets.insert(:day17, {:max_seq_cont, max_seq_cont})

    File.stream!(path)
    |> parse()
    |> map_with_maxs()
    |> least_heat()
  end

  defp least_heat(map_bag) do
    seen = MapSet.new()
    start = {{0, 0}, {0, 0}}
    pqueue = PQueue.new({0, {start, 0}})

    follow_path(map_bag, seen, pqueue)
  end
  
  defp follow_path({_, max_x, max_y} = map_bag, seen, pqueue) do
    {{heat_loss, {node, _} = p}, pqueue} = PQueue.pop_min!(pqueue)
    {{x, y}, _} = node

    if x == max_x and y == max_y do
      heat_loss
    else
      follow_path(p, heat_loss, map_bag, seen, pqueue)
    end
  end

  defp follow_path(p, heat_loss, map_bag, seen, pqueue) do
    if p in seen do
      follow_path(map_bag, seen, pqueue)
    else
      seen = MapSet.put(seen, p)
      
      pqueue = follow_path(p, heat_loss, map_bag, pqueue)
      follow_path(map_bag, seen, pqueue)
    end
  end

  defp follow_path({{curr_pos, curr_dir}, seq_cont}, heat_loss, {map, max_x, max_y}, pqueue) do
    [{_, max_seq_cont}] = :ets.lookup(:day17, :max_seq_cont)
    [{_, min_seq_cont}] = :ets.lookup(:day17, :min_seq_cont)

    pqueue = if curr_dir != {0, 0} and seq_cont < max_seq_cont do
      next_pos = Point.add(curr_pos, curr_dir)
      if in_map_bounds?(next_pos, max_x, max_y) do
        PQueue.push(pqueue, heat_loss + Map.get(map, next_pos), {{next_pos, curr_dir}, seq_cont + 1})
      else
        pqueue
      end
    else
      pqueue
    end
    
    if curr_dir == {0, 0} or seq_cont >= min_seq_cont do
      directions()
      |> Enum.reject(&(&1 == curr_dir or &1 == Point.neg(curr_dir)))
      |> Enum.reduce(pqueue, fn d, pq ->
        next_pos = Point.add(curr_pos, d)
        if in_map_bounds?(next_pos, max_x, max_y) do
          PQueue.push(pq, heat_loss + Map.get(map, next_pos), {{next_pos, d}, 1})
        else
          pq 
        end
      end)
    else
      pqueue
    end    
  end

  defp in_map_bounds?({x, y}, max_x, max_y), do: (0 <= x and x <= max_x) and (0 <= y and y <= max_y)
  
  defp directions(), do: [{1, 0}, {-1, 0}, {0, 1}, {0, -1}]

  defp map_with_maxs(map),
    do:
      map
      |> Enum.reduce({0, 0}, fn {{x, y}, _}, {mx, my} ->
        { (if x > mx, do: x, else: mx), (if y > my, do: y, else: my) }
      end)
      |> then(fn {max_x, max_y} -> {map, max_x, max_y} end)

  defp parse(fstream), do: Stream.with_index(fstream) |> Enum.reduce(%{}, &parse_line/2)

  defp parse_line({l, y}, map),
    do: l
      |> String.trim_trailing("\n")
      |> String.split("", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> Enum.with_index()
      |> Enum.reduce(map, &Map.put(&2, {elem(&1, 1), y}, elem(&1, 0)))
end

Path.expand("~/dev/advent_of_code/aoc2023/inputs/day17")
|> Day17.part_2()
|> IO.inspect(label: "result")
