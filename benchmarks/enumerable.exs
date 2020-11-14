Benchee.run(
  [
    # "patched2: Enum.Patched2.empty?/1": &Enum.Patched2.empty?(&1),
    "patched: Enum.Patched.empty?/1": &Enum.Patched.empty?(&1),
    "original: Enum.empty?/1": &Enum.empty?(&1)
  ],
  inputs: [
    list_empty: [],
    list_100: Enum.to_list(1..100),
    list_10_000: Enum.to_list(1..10_000),
    map_empty: %{},
    map_100: Enum.into(1..100, %{}, &{&1, &1}),
    map_10_000: Enum.into(1..10_000, %{}, &{&1, &1})
  ],
  time: 2
  # memory_time: 2
)
