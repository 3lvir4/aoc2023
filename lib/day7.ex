defmodule Day7 do
  def part_1(path) do
    File.stream!(path)
    |> Enum.reduce([], &parse_line/2)
    |> Enum.sort(&compare_hands(&1, &2, 1))
    |> Stream.with_index()
    |> Enum.reduce(0, fn {{_, bid}, i}, acc -> acc + bid * (i + 1) end)
  end

  def part_2(path) do
    File.stream!(path)
    |> Enum.reduce([], &parse_line/2)
    |> Enum.sort(&compare_hands(&1, &2, 2))
    |> Stream.with_index()
    |> Enum.reduce(0, fn {{_, bid}, i}, acc -> acc + bid * (i + 1) end)
  end

  defp compare_hands({h1, _}, {h2, _}, part) do
    sh1 = if part == 1, do: strength(h1), else: strength_wjoker(h1)
    sh2 = if part == 1, do: strength(h2), else: strength_wjoker(h2)
    cond do
      sh1 < sh2 -> true
      sh1 > sh2 -> false
      sh1 == sh2 ->
        {result, _} = Enum.reduce_while(h1, {true, h2}, fn h1_c, { res, [h2_c | h2_tl] } -> 
          h1_cval = card_to_val(h1_c)
          h2_cval = card_to_val(h2_c)
          cond do              h1_cval < h2_cval -> {:halt, {res, []}}
            h1_cval > h2_cval -> {:halt, {false, []}}
            h1_cval == h2_cval -> {:cont, {res, h2_tl}}
          end
        end)
        result
    end
  end

  defp strength_wjoker(hand) do
    {maxfreq_card, _} = Enum.frequencies(hand)
    |> Enum.max(fn {c1, f1}, {c2, f2} -> 
      cond do
        c1 == "J" -> false
        c2 == "J" -> true
        true -> f1 >= f2
      end
    end)

    Enum.map(hand, fn c -> if c == "J", do: maxfreq_card, else: c end)
    |> strength()
  end

  defp strength(hand) do
    hand
    |> Enum.reduce_while({[0, 0, 0, 0, 0], 0, []}, fn curr, {acc, i, done} ->
      if Enum.sum(acc) == 5 do
        {:halt, {acc, i, done}}
      else
        if Enum.any?(done, &(&1 == curr)) do
          {:cont, {acc, i, done}}
        else
          count = Enum.count(hand, fn v -> v == curr end)
          updacc = List.update_at(acc, i, fn n -> n + count end)
          {:cont, {updacc, i + 1, [curr | done]}}
        end
      end
    end)
    |> then(fn {counts, _, _} -> List.to_tuple(counts) end)
    |> counts_to_strength()
  end

  defp card_to_val("A"), do: 14
  defp card_to_val("K"), do: 13
  defp card_to_val("Q"), do: 12
  #defp card_to_val("J"), do: 11
  defp card_to_val("J"), do: 1
  defp card_to_val("T"), do: 10
  defp card_to_val(n), do: String.to_integer(n)

  defp counts_to_strength({5, _, _, _, _}), do: 6
  defp counts_to_strength({4, 1, _, _, _}), do: 5
  defp counts_to_strength({1, 4, _, _, _}), do: 5
  defp counts_to_strength({3, 2, _, _, _}), do: 4
  defp counts_to_strength({2, 3, _, _, _}), do: 4
  defp counts_to_strength({3, _, _, _, _}), do: 3
  defp counts_to_strength({_, 3, _, _, _}), do: 3
  defp counts_to_strength({_, _, 3, _, _}), do: 3
  defp counts_to_strength({2, 2, _, _, _}), do: 2
  defp counts_to_strength({_, 2, 2, _, _}), do: 2
  defp counts_to_strength({2, _, 2, _, _}), do: 2
  defp counts_to_strength({2, _, _, _, _}), do: 1
  defp counts_to_strength({_, 2, _, _, _}), do: 1
  defp counts_to_strength({_, _, 2, _, _}), do: 1
  defp counts_to_strength({_, _, _, 2, _}), do: 1
  defp counts_to_strength(_), do: 0

  defp parse_line(l, acc) do
    String.split(l, " ")
    |> List.to_tuple()
    |> then(fn {hand, bid} ->
      { String.split(hand, "", trim: true), bid |> String.trim_trailing() |> String.to_integer()}
    end)
    |> then(fn p -> [p | acc] end)
  end
end

Path.expand("~/dev/advent_of_code/aoc2023/inputs/day7")
|> Day7.part_2()
|> IO.inspect(label: "result")
