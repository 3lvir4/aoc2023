defmodule Day19 do
  alias Day19.Rule

  @type workflow() :: %{rules: list(Rule.t()), default: String.t()}

  defmodule Rule do
    @enforce_keys [:rating, :comparator, :base, :target]
    defstruct @enforce_keys
    @type t() :: %__MODULE__{rating: :x | :m | :a | :s, comparator: :lt | :gt, base: integer(), target: String.t()}
    
    @type rating() :: :x | :m | :a | :s

    @type part() :: %{:x => integer(), :m => integer(), :a => integer(), :s => integer()}
    @type rating_ranges() :: %{:x => Range.t(), :m => Range.t(), :a => Range.t(), :s => Range.t()}

    @spec assert(Rule.t(), part()) :: {:jump, part(), String.t()} | {:cont, part()}
    def assert(rule = %Rule{}, part) do
      if pass?(rule.comparator, part[rule.rating], rule.base) do
        {:jump, part, rule.target}
      else
        {:cont, part}
      end
    end

    @spec assert_ranges(Rule.t(), rating_ranges()) :: %{jump: {Range.t(), String.t()}, cont: Range.t(), rating: rating()}
    def assert_ranges(rule = %Rule{}, ranges) do
      lower..upper = ranges[rule.rating]

      case rule.comparator do
        :lt -> %{
          jump: {lower..min(rule.base - 1, upper)//1, rule.target},
          cont: max(rule.base, lower)..upper//1,
          rating: rule.rating
        }

        :gt -> %{
          jump: {max(rule.base + 1, lower)..upper//1, rule.target},
          cont: lower..min(rule.base, upper)//1,
          rating: rule.rating
        }
      end
    end

    defp pass?(:lt, value, base), do: value < base
    defp pass?(:gt, value, base), do: value > base
  end

  def part_1(path) do
    File.stream!(path)
    |> parse()
    |> accepted_parts()
    |> Enum.map(&(&1.x + &1.m + &1.a + &1.s))
    |> Enum.sum()
  end

  def part_2(path) do
    File.stream!(path)
    |> parse()
    |> elem(0)
    |> then(&proc_ranges(rating_ranges(), "in", &1, 0))
  end

  defp rating_ranges(), do: Enum.zip([:x, :m, :a, :s], List.duplicate(1..4000//1, 4)) |> Enum.into(%{})

  defp proc_ranges(_, "R", _, _), do: 0
  defp proc_ranges(ranges, "A", _, _), do: Enum.reduce(Map.values(ranges), 1, &(&2 * Range.size(&1)))

  defp proc_ranges(ranges, workflow_name, workflows, count_accepted) do
    %{rules: rules, default: default} = Map.get(workflows, workflow_name)

    {ranges, count_accepted} =
      for rule <- rules, reduce: {ranges, count_accepted} do
        {rgs, count} ->
          %{jump: {rg_jump, target}, cont: rg_cont, rating: rating} = Rule.assert_ranges(rule, rgs)
          { 
            Map.replace(rgs, rating, rg_cont),
            count + proc_ranges(Map.replace(rgs, rating, rg_jump), target, workflows, 0)
          }
      end
    
    count_accepted + proc_ranges(ranges, default, workflows, 0)
  end

  defp accepted_parts({workflows, parts}), do: Enum.reduce(parts, [], &proc_part(&1, "in", workflows, &2))

  defp proc_part(part, workflow_name, workflows, accepted) do
    %{rules: rules, default: default} = Map.get(workflows, workflow_name)
    
    case rules_check(part, rules, default) do
      "A" -> [part | accepted]
      "R" -> accepted
      name -> proc_part(part, name, workflows, accepted)
    end
  end

  defp rules_check(_, [], default), do: default
  defp rules_check(part, [rule | rest], default) do
    case Rule.assert(rule, part) do
      {:jump, _, target} -> target
      {:cont, part} -> rules_check(part, rest, default)
    end
  end

  @spec parse(File.Stream.t()) :: {%{String.t() => workflow()}, [Rule.part()]}
  defp parse(fstream) do
    [workflows, parts] = fstream
    |> Stream.chunk_by(&(&1 == "\n"))
    |> Stream.reject(&(&1 == ["\n"]))
    |> Stream.map(&Enum.map(&1, fn l -> String.trim_trailing(l, "\n") end))
    |> Enum.to_list()

    parts = Enum.reduce(parts, [], &parse_part/2)
    workflows = Enum.reduce(workflows, %{}, &parse_workflow/2)

    {workflows, parts}
  end

  @spec parse_part(String.t(), [Rule.part()]) :: [Rule.part()]
  defp parse_part(str, parts) do
    part = String.slice(str, 1..-2//1)
    |> String.split(",", trim: true)
    |> Enum.reduce(%{}, fn rs, part ->
      <<key::binary-size(1), ?=, value::binary>> = rs
      Map.put(part, String.to_atom(key), String.to_integer(value))
    end)

    [part | parts]
  end
 
  @spec parse_workflow(String.t(), %{String.t() => workflow()}) :: %{String.t() => workflow()}
  defp parse_workflow(str, workflows) do
    {name, rules} = str
    |> String.trim_trailing("}")
    |> String.split("{", trim: true)
    |> List.to_tuple()
    
    workflow = String.split(rules, ",", trim: true) |> rules_to_workflow([])
    
    Map.put(workflows, name, workflow)
  end

  defp rules_to_workflow([rule_str | rest], rules) do
    if String.contains?(rule_str, ":") do
      rules_to_workflow(rest, [parse_rule(rule_str) | rules])
    else
      %{rules: Enum.reverse(rules), default: rule_str}
    end
  end

  defp parse_rule(str) do
    [comparison, target] = String.split(str, ":", trim: true)
    <<rating::binary-size(1), comparator::binary-size(1), base::binary>> = comparison

    %Rule{
      rating: String.to_atom(rating),
      comparator: parse_comparator(comparator),
      base: String.to_integer(base),
      target: target
    }
  end

  defp parse_comparator("<"), do: :lt
  defp parse_comparator(">"), do: :gt
end

Path.expand("~/dev/advent_of_code/aoc2023/inputs/day19")
|> Day19.part_2()
|> IO.inspect(label: "result")
