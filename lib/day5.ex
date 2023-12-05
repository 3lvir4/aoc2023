defmodule Day5 do
  @doc """
    Do not run this unless you want to burn your computer
  """
  def part_1_original(path) do
    File.read!(path)
    |> String.split(["\n", " map:"], trim: true)
    |> parse_input()
    |> lowest_location()
  end

  def part_1_not_killing_computer(path) do
    File.read!(path)
    |> String.split(["\n", " map:"], trim: true)
    |> parse()
    |> (fn {seeds, maps} -> Enum.map(seeds, &(seed_to_location(&1, maps))) end).()
    |> Enum.min()
  end

  defp seed_to_location(seed, maps) do
    maps
    |> Enum.reduce(seed, fn map, prev -> 
      Enum.reduce_while(map, prev, fn {first.._ = range, first_dst}, n ->
        if n in range do
          {:halt, n - first + first_dst}
        else
          {:cont, n}
        end
      end)
    end)
  end

  defp parse(lines) do
    [hd | tl] = lines

    chunks = (fn [_ | rest] -> chunk_maps(rest) end).(tl)

    seeds = hd
    |> String.trim()
    |> String.split(": ", trim: true)
    |> (fn [_, s] -> String.split(s) end).()
    |> Enum.map(&String.to_integer/1)
    
    maps = chunks
    |> Enum.map(&(Enum.map(&1, fn [dst, src, len] -> {src..src+len-1, dst} end)))

    {seeds, maps}
  end

  defp chunk_maps(lines) do
    lines
    |> Enum.chunk_while([], fn l, acc ->
      if Regex.match?(~r/\-/, l) do
        {:cont, [l | acc], []}
      else
        {:cont, [l | acc]}
      end
    end, fn
      [] -> {:cont, []}
      acc -> {:cont, acc, []}
    end)
    |> Enum.map(fn chunk -> 
      [hd|tl] = chunk
      if Regex.match?(~r/\-/, hd) do
        tl
      else
        chunk
      end
      |> Enum.map(fn s ->
        String.split(s)
        |> Enum.map(&String.to_integer/1)
      end)
    end)
  end

  defp lowest_location({seeds, pipeline}) do
    superfun = fn arg -> Enum.reduce(pipeline, arg, &(&1.(&2))) end

    seeds
    |> Enum.map(fn n -> superfun.(n) end)
    |> Enum.min()
  end

  defp parse_input(lines) do
    [hd | tl] = lines
    
    seeds = hd
    |> String.trim()
    |> String.split(": ", trim: true)
    |> (fn [_, s] -> String.split(s) end).()
    |> Enum.map(&String.to_integer/1)
    
    [_ | rest] = tl
    funs = parse_maps(rest)

    {seeds, funs}
  end
  
  defp parse_maps(lines) do
    lines
    |> Enum.chunk_while([], fn l, acc ->
      if Regex.match?(~r/\-/, l) do
        {:cont, [l | acc], []}
      else
        {:cont, [l | acc]}
      end
    end, fn
      [] -> {:cont, []}
      acc -> {:cont, acc, []}
    end)
    |> Enum.map(fn chunk -> parse_map_chunk(chunk) end)
  end

  defp parse_map_chunk(chunk) do
    [hd | tl] = chunk
    data = if Regex.match?(~r/\-/, hd) do
      tl
    else
      chunk
    end

    map = data
    |> Enum.map(fn s -> String.split(s) |> Enum.map(&String.to_integer/1) end)
    |> Enum.reduce(Map.new(), fn [dst, src, len], acc ->
      0..len-1
      |> Enum.reduce(acc, fn i, m  -> Map.put(m, src + i, dst + i) end)
    end)
    
    fn n -> Map.get(map, n, n)  end
  end
end

Path.expand("~/dev/advent_of_code/aoc2023/inputs/day5")
|> Day5.part_1_not_killing_computer()
|> IO.inspect()
