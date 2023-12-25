defmodule Day20 do
  alias Day20.Queue, as: Queue
  alias Day8

  @type pulse :: :low | :high
  @type message :: {binary(), binary(), pulse()}

  defmodule Queue do
    @type t :: :queue.queue()

    @spec new() :: t()
    @spec new(Enumerable.t()) :: t()
    def new(), do: :queue.new()
    def new(list) when is_list(list), do: :queue.from_list(list)
    def new(enum), do: new(Enum.to_list(enum))

    @spec enqueue(t(), any()) :: t()
    def enqueue(queue, value), do: :queue.in(value, queue)

    @spec dequeue(t(), any()) :: {any(), t()}
    def dequeue(queue, default \\ nil) do
      case :queue.out(queue) do
        {{:value, value}, q} -> {value, q}
        {:empty, q} -> {default, q}
      end
    end

    @spec empty?(t()) :: boolean()
    def empty?(queue), do: :queue.is_empty(queue)

    @spec add(t(), t()) :: t()
    def add(q1, q2), do: :queue.join(q1, q2)
  end

  defmodule Mod do
    @type t :: {:flip, 0 | 1} | {:conj, %{binary() => pulse()}} | {:broadcast, nil}
    @type pulse :: Day20.pulse()

    @spec handle(t(), pulse(), binary()) :: {:some, pulse(), t()} | {:none, t()}
    def handle({:broadcast, _} = mod, pulse, _), do: {:some, pulse, mod}
    def handle({:flip, 1}, :low, _), do: {:some, :low, {:flip, 0}}
    def handle({:flip, 0}, :low, _), do: {:some, :high, {:flip, 1}}
    def handle({:flip, _} = mod, :high, _), do: {:none, mod}
    
    def handle({:conj, memo}, pulse, sender) do
      memo = Map.put(memo, sender, pulse)
      res = if Map.values(memo) |> Enum.all?(&(&1 == :high)), 
        do: :low, 
        else: :high
      {:some, res, {:conj, memo}}
    end
  end

  def part_1(path) do
    File.read!(path)
    |> parse()
    |> press_button_stream()
    |> Stream.take(1000)
    |> Stream.flat_map(&Enum.map(&1, fn {_, _, pulse} -> pulse end))
    |> Enum.reduce({0, 0}, fn pulse, {nb_low, nb_high} ->
      case pulse do
        :low -> {nb_low + 1, nb_high}
        :high -> {nb_low, nb_high + 1}
      end
    end)
    |> then(fn {nb_low, nb_high} -> nb_low * nb_high end)
  end

  def part_2(path) do
    # in my puzzle input, only the module &qn is pointing to &rx
    # also 4 conj modules pointing to &qn
    {config, mods} = File.read!(path) |> parse()
    outputs_to_qn = Enum.filter(config, fn {_, dests} -> "qn" in dests end) |> Enum.map(&elem(&1, 0))

    press_button_stream({config, mods})
    |> Stream.map(&Enum.filter(&1, fn {sender, _, pulse} -> sender in outputs_to_qn and pulse == :high end)) 
    |> Stream.with_index(1)
    |> Stream.reject(&(elem(&1,0) == []))
    # at most one message outgoing to &qn
    # |> Enum.take(50)
    |> Stream.map(fn {[{sender, _, _}], nb_press} -> {sender, nb_press} end)
    |> Enum.reduce_while([], fn {sender, nb_press}, diffs_seen ->
      if length(diffs_seen) == 4 do
        {:halt, Enum.map(diffs_seen, &elem(&1, 1))}
      else
        if Enum.any?(diffs_seen, & elem(&1, 0) == sender) do
          {:cont, diffs_seen}
        else
          {:cont, [{sender, nb_press} | diffs_seen]}
        end
      end
    end)
    |> Enum.reduce(&Day8.ppcm/2)
  end

  defp press_button_stream({config, mods}) do    
    run_config(mods, config)
    |> Stream.iterate(fn {_, mods} -> run_config(mods, config) end)
    |> Stream.map(&elem(&1, 0))
  end

  defp run_config(mods, config),
    do: run_config(Queue.new([{"button", "broadcaster", :low}]), [], mods, config)

  defp run_config(queue, sent, mods, config) do
    if Queue.empty?(queue) do
      {sent, mods}
    else
      {msg, queue} = Queue.dequeue(queue)
      {to_send, mods} = proc_msg(msg, mods, config)
      to_send = Queue.new(to_send)
      run_config(Queue.add(queue, to_send), [msg | sent], mods, config)
    end
  end

  defp proc_msg({sender, dest, pulse}, mods, config) do
    outputs = if (t = Map.get(config, dest)) != nil, do: t, else: []
    target = Map.get(mods, dest)

    if target == nil do
      {[], mods}
    else
      case Mod.handle(target, pulse, sender) do
        {:some, pulse, mod} -> {Enum.map(outputs, &{dest, &1, pulse}), Map.put(mods, dest, mod)}
        {:none, _} -> {[], mods}
      end
    end
  end

  defp parse(input) do
    config = for l <- String.split(input, "\n", trim: true), into: %{} do
      [src, dests] = String.split(l, " -> ")
      {type, name} = parse_src(src)
      {name, {type, parse_dests(dests)}}
    end

    mods = init_mods(config)
    config = Enum.map(config, fn {name, {_, dests}} -> {name, dests} end) |> Enum.into(%{})

    {config, mods}
  end

  defp init_mods(config) do
    conj_names = Enum.filter(config, fn {_, {type, _}} -> type == :conj end) |> Enum.map(&elem(&1, 0))
    conj_incomings = for n <- conj_names, do: {n, []}, into: %{}

    conj_incomings =
      Enum.reduce(config, conj_incomings, fn {name, {_, dests}}, acc ->
        for dest <- Enum.filter(dests, &(&1 in conj_names)), reduce: acc do
          acc -> Map.update!(acc, dest, &[name | &1])
        end
      end)

    Enum.map(config, fn
      {name, {:broadcast, _}} -> {name, {:broadcast, nil}}
      {name, {:flip, _}} -> {name, {:flip, 0}}
      {name, {:conj, _}} ->
        memo = for n <- conj_incomings[name], do: {n, :low}, into: %{}
        {name, {:conj, memo}}
    end)
    |> Enum.into(%{})
  end

  defp parse_dests(dests), do: String.split(dests, ", ", trim: true)

  defp parse_src(<<"%", name::binary>>), do: {:flip, name}
  defp parse_src(<<"&", name::binary>>), do: {:conj, name}
  defp parse_src("broadcaster"), do: {:broadcast, "broadcaster"}
end

Path.expand("~/dev/advent_of_code/aoc2023/inputs/day20")
|> Day20.part_2()
|> IO.inspect(label: "result")
