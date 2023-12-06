defmodule Day5.Part2 do

  def handle(path) do
    File.stream!(path)
    |> Enum.to_list()
    |> (fn [hd|tl] -> {parse_header(hd), parse_maps(tl)} end).()
    |> calc_minimums()
  end

  defp calc_minimums({seeds, maps}) do
    maps
    |> Enum.reduce(seeds, fn map, srngs ->
      Stream.unfold(srngs, fn
        [] -> nil
        seed_ranges -> for seed_range <- seed_ranges, reduce: {[], []}  do
          {done, remaining} ->
            res = Enum.find_value(map, seed_range, &handle_intersection_mapping(&1, seed_range))

            case res do
              {intersection, rest} -> {[intersection | done], rest ++ remaining}
              _.._ = intersection -> {[intersection | done], remaining}
            end
        end
      end)
      |> Enum.to_list()
      |> List.flatten()
    end)
    |> Enum.min()
    |> Enum.min()
  end

  defp handle_intersection_mapping({fsrc..endsrc, fdst}, fseed..endseed) do
    left_intersection_bound = max(fseed, fsrc)
    right_intersection_bound = min(endseed, endsrc)
    
    unless left_intersection_bound > right_intersection_bound do
      intersection = left_intersection_bound..right_intersection_bound
      |> Range.shift(fdst - fsrc)

      left = if fseed < left_intersection_bound do
        [fseed..left_intersection_bound-1]
      else
        []
      end

      right = if right_intersection_bound < endseed do
        [right_intersection_bound+1..endseed]
      else
        []
      end

      {intersection, left ++ right}
    end
  end

  defp parse_maps([_|lines]) do
    lines
    |> Enum.reduce([], fn l, acc ->
      if Regex.match?(~r/\-/, l) do
        acc
      else 
        maps = l
        |> String.replace_suffix("\n", "")
        |> String.split(" ", trim: true)
        |> Enum.map(&String.to_integer/1)
        |> List.to_tuple()
        [maps | acc]
      end
    end)
    |> Enum.reverse()
    |> Enum.chunk_by(fn x -> x == {} end)
    |> Enum.reject(fn c -> c == [{}] end)
    |> Enum.map(fn chunk -> chunk
      |> Enum.map(fn {dst, src, len} -> {src..src+len-1, dst} end)
    end)
  end

  defp parse_header("seeds: " <> data), do: seed_ranges(data)

  defp seed_ranges(data) do
    data
    |> String.split()
    |> Enum.map(&String.to_integer/1)
    |> Enum.chunk_every(2)
    |> Enum.map(fn [start, len] -> start..start+len-1 end)
  end
end

Path.expand("~/dev/advent_of_code/aoc2023/inputs/day5")
|> Day5.Part2.handle()
|> IO.inspect()
