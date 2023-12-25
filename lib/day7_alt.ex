defmodule Day7Alt do
  import Bitwise

  def part_1(path) do
    File.stream!(path)
    |> Stream.map(&parse_line/1)
    |> Enum.sort(& elem(&1, 0) <= elem(&2, 0))
    |> Enum.map(&elem(&1, 1))
    |> Enum.with_index(1)
    |> Enum.reduce(0, fn {bid, i}, acc -> acc + i * bid end)
  end

  defp parse_line(l),
    do: l
        |> String.trim_trailing("\n")
        |> String.split(" ")
        |> then(fn [h, b] -> {parse_hand(h), String.to_integer(b)} end)

  defp parse_hand(hand) do
    chars = String.graphemes(hand)

    hand_strength = 
      chars
      |> Enum.frequencies()
      |> Map.values()
      |> strength_hand()
      |> Bitwise.<<<(20)
    
    parse_hand(chars, hand_strength)
  end

  defp parse_hand(chars, hand_strength), do: parse_hand(chars, hand_strength, 16)

  defp parse_hand([], strength, _), do: strength
  defp parse_hand([c | rest], strength, shift), do: parse_hand(rest, strength + (strength_card(c) <<< shift), shift - 4)

  defp strength_hand(cards), do: strength_hand(cards, 1)

  defp strength_hand([], strength), do: strength
  defp strength_hand([5 | _], _), do: 7
  defp strength_hand([4 | _], _), do: 6
  defp strength_hand([3 | rest], strength), do: strength_hand(rest, strength + 3)
  defp strength_hand([2 | rest], strength), do: strength_hand(rest, strength + 1)
  defp strength_hand([_ | rest], strength), do: strength_hand(rest, strength)

  defp strength_card("A"), do: 14
  defp strength_card("K"), do: 13
  defp strength_card("Q"), do: 12
  defp strength_card("J"), do: 11
  defp strength_card("T"), do: 10
  defp strength_card(n), do: String.to_integer(n)
end

Path.expand("~/dev/advent_of_code/aoc2023/inputs/day7")
|> Day7Alt.part_1()
|> IO.inspect(label: "result")
