defmodule Whitespace.Parser do

  def tokenize([]), do: []
  def tokenize(["\s" | xs]), do: [ :A | tokenize xs ]
  def tokenize(["\t" | xs]), do: [ :B | tokenize xs ]
  def tokenize(["\n" | xs]), do: [ :C | tokenize xs ]
  def tokenize([_ | xs]),    do: tokenize(xs)

  def parse(x) do
    x
  end

  def parse_number(x), do: parse_number_acc(x, [])

  defp parse_number_acc([:C | xs], acc), do: { make_number(acc), xs }
  defp parse_number_acc([x | xs], acc),  do: parse_number_acc(xs, [x | acc])

  defp make_number(x) do
    cond do
      List.last(x) == :A -> make_number_acc(drop_last(x), 1)
      true               -> -make_number_acc(drop_last(x), 1)
    end
  end

  defp drop_last([]),       do: []
  defp drop_last([x]),      do: []
  defp drop_last([x | xs]), do: [ x | drop_last(xs) ]

  defp make_number_acc([], _),          do: 0
  defp make_number_acc([:A | xs], pow), do: make_number_acc(xs, pow*2)
  defp make_number_acc([:B | xs], pow), do: (pow + make_number_acc(xs, pow*2))

  def parse_string(x), do: parse_string_acc(x, [])

  defp parse_string_acc([:C | xs], acc), do: { make_string(acc), xs }
  defp parse_string_acc([x | xs], acc),  do: parse_string_acc(xs, [x | acc])

  defp make_string([]), do: ""
  defp make_string([:A | xs]), do: (make_string(xs) <> "\s")
  defp make_string([:B | xs]), do: (make_string(xs) <> "\t")
end