defmodule Aoc2023 do
  def day11() do
    path = Path.expand("~/dev/advent_of_code/aoc2023/inputs/day11")
    
    path
    |> Day11.part_1()
    |> IO.inspect(label: "Day 11 | Part 1")
    
    path
    |> Day11.part_2()
    |> IO.inspect(label: "Day 11 | Part 2")
  end
end
