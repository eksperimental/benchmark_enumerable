defmodule EmptyMap do
  def guard(map) when map == %{},
    do: true

  def guard(_),
    do: false

  def size(map), do: map_size(map) == 0

  def equal(map),
    do: map == %{}
end

Benchee.run(
  [
    "guard/1": &EmptyMap.guard(&1),
    "size/1": &EmptyMap.size(&1),
    "equal/1": &EmptyMap.equal(&1)
  ],
  inputs: [
    # list_empty: [],
    # list_100: Enum.to_list(1..100),
    # list_10_000: Enum.to_list(1..10_000),
    map_empty: %{},
    map_100: Enum.into(1..100, %{}, &{&1, &1}),
    map_10_000: Enum.into(1..10_000, %{}, &{&1, &1})
  ],
  time: 2,
  memory_time: 2
)
