defprotocol Enumerable.Patched do
  def reduce(enumerable, acc, fun)
  def count(enumerable)
  def member?(enumerable, element)
  def slice(enumerable)
end

defimpl Enumerable.Patched, for: List do
  def count([]), do: {:ok, 0}
  def count(_list), do: {:error, __MODULE__}

  def member?([], _value), do: {:ok, false}
  def member?(_list, _value), do: {:error, __MODULE__}

  def slice([]), do: {:ok, 0, fn _, _ -> [] end}
  def slice(_list), do: {:error, __MODULE__}

  def reduce(_list, {:halt, acc}, _fun), do: {:halted, acc}
  def reduce(list, {:suspend, acc}, fun), do: {:suspended, acc, &reduce(list, &1, fun)}
  def reduce([], {:cont, acc}, _fun), do: {:done, acc}
  def reduce([head | tail], {:cont, acc}, fun), do: reduce(tail, fun.(head, acc), fun)

  def slice(_list, _start, 0, _size), do: []
  def slice(_list, _start, _count, 0), do: []
  def slice(list, start, count, size) when start + count == size, do: drop(list, start)
  def slice(list, start, count, _size), do: list |> drop(start) |> take(count)

  defp drop(list, 0), do: list
  defp drop([_ | tail], count), do: drop(tail, count - 1)

  defp take(_list, 0), do: []
  defp take([head | tail], count), do: [head | take(tail, count - 1)]
end

defimpl Enumerable.Patched, for: Map do
  def count(map) do
    {:ok, map_size(map)}
  end

  def member?(map, {key, value}) do
    {:ok, match?(%{^key => ^value}, map)}
  end

  def member?(_map, _other) do
    {:ok, false}
  end

  def slice(map) do
    case map_size(map) do
      0 ->
        {:ok, 0, fn _, _ -> [] end}

      size ->
        {:ok, size, &Enumerable.Patched.List.slice(:maps.to_list(map), &1, &2, size)}
    end
  end

  def reduce(map, acc, fun) do
    Enumerable.Patched.List.reduce(:maps.to_list(map), acc, fun)
  end
end

defmodule Enum.Patched do
  @compile :inline_list_funcs

  def empty?(enumerable) when is_list(enumerable) do
    enumerable == []
  end

  def empty?(enumerable) do
    case Enumerable.Patched.slice(enumerable) do
      {:ok, value, _} ->
        value == 0

      {:error, module} ->
        enumerable
        |> module.reduce({:cont, true}, fn _, _ -> {:halt, false} end)
        |> elem(1)
    end
  end
end
