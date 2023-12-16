defmodule Day15 do
  import Bitwise
  
  defmodule HASHMAP do
    @type lens() :: {[binary()], pos_integer()}
    @type boxes() :: %{pos_integer() => [lens()]}
    
    @spec exec(boxes(), <<_::1>>, [binary()], 1..9|nil) :: boxes()
    def exec(map, "-", label, _), do: remove(map, label)
    def exec(map, "=", label, focal_len), do: assign(map, label, focal_len)

    defp remove(map, label) do
      i = Day15.hash_seq(label)
      label = Enum.join(label)
      if Map.has_key?(map, i), do: delete(map, i, label), else: map
    end

    defp assign(map, label, focal_len) do
      i = Day15.hash_seq(label)
      label = Enum.join(label)
      case Map.has_key?(map, i) do
        true -> update(map, i, label, focal_len)
        false -> Map.put(map, i, [{label, focal_len}])
      end
    end

    defp delete(map, i, label) do
      Map.update!(map, i, fn curr ->
        if j = Enum.find_index(curr, fn {l, _} -> l == label end) do
          List.delete_at(curr, j)
        else
          curr
        end
      end)
    end

    defp update(map, i, label, focal_len) do
      Map.update!(map, i, fn curr ->
        if j = Enum.find_index(curr, fn {l, _} -> l == label end) do
          List.update_at(curr, j, fn {l, _} -> {l, focal_len} end)
        else
          [{label, focal_len} | curr]
        end
      end)
    end
  end

  def part_1(path) do
    File.stream!(path, [], 1)
    |> parse()
    |> Stream.map(&hash_seq/1)
    |> Enum.sum()
  end

  def part_2(path) do
    File.stream!(path, [], 1)
    |> parse()
    |> Enum.reduce(%{}, fn chars, boxes ->
      {op, label, focal_len} = init_seq(chars)
      HASHMAP.exec(boxes, op, label, focal_len)
    end)
    |> Stream.map(fn {i, lenses} -> {i + 1, lenses} end)
    |> Stream.map(fn {box, lenses} ->
      Enum.reverse(lenses)
      |> Enum.with_index(1)
      |> Enum.reduce(0, fn {lens, slot}, acc -> acc + focus_power(lens, box, slot) end)
    end)
    |> Enum.sum()
  end

  defp focus_power({_, focal_len}, box, slot), do: box * slot * focal_len

  defp init_seq(chars), do: init_seq(chars, [], nil, nil)

  defp init_seq([], lbl, op, focal_len), do: {op, Enum.reverse(lbl), focal_len}
  defp init_seq([c | tl], lbl, "=", nil), do: init_seq(tl, lbl, "=", String.to_integer(c))
  defp init_seq([c | tl], lbl, nil, nil) when c in ["-", "="], do: init_seq(tl, lbl, c, nil)
  defp init_seq([c | tl], lbl, nil, nil), do: init_seq(tl, [c | lbl], nil, nil)
  
  def hash_seq(chars), do: hash_seq(chars, 0)

  defp hash_seq([], acc), do: acc
  defp hash_seq([c | rest], acc), do: hash_seq(rest, hash(c, acc))

  defp hash(c, acc), do: (acc + ascii(c)) * 17 |> band((1 <<< 8) - 1)

  defp ascii(<<v::utf8>> = c) when byte_size(c) == 1, do: v
  defp ascii(_), do: raise ArgumentError

  defp parse(input),
    do: input
      |> Stream.chunk_by(fn c -> c in [",", "\n"] end)
      |> Stream.reject(fn s -> s == ["\n"] or s == [","] end)
end

Path.expand("~/dev/advent_of_code/aoc2023/inputs/day15")
|> Day15.part_2()
|> IO.inspect()
