defmodule Whitespace.Parser do

  def tokenize([]), do: []
  def tokenize(["\s" | xs]), do: [ :A | tokenize xs ]
  def tokenize(["\t" | xs]), do: [ :B | tokenize xs ]
  def tokenize(["\n" | xs]), do: [ :C | tokenize xs ]
  def tokenize([_ | xs]),    do: tokenize(xs)

  def parse(x) do
    x
  end

  def parse_number(x) do
    x
  end

  def parse_string(x) do
    parse_string_acc(x, [])
  end

  defp parse_string_acc([:C | xs], acc) do
    { make_string(acc), xs }
  end

  defp parse_string_acc([x | xs], acc) do
    parse_string_acc(xs, [x | acc])
  end

  defp make_string([]), do: ""
  defp make_string([:A | xs]), do: (make_string(xs) <> "\s")
  defp make_string([:B | xs]), do: (make_string(xs) <> "\t")
end