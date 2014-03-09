defmodule Whitespace.Parser do

  def tokenize([]), do: []
  def tokenize(["\s" | xs]), do: [ :A | tokenize xs ]
  def tokenize(["\t" | xs]), do: [ :B | tokenize xs ]
  def tokenize(["\n" | xs]), do: [ :C | tokenize xs ]
  def tokenize([_ | xs]),    do: tokenize(xs)

  def parse([]), do: []

  def parse([:A, :A | xs]) do
    { number, rest } = parse_number(xs)
    [ {:Push, number} | parse(rest) ]
  end

  def parse([:A, :B, :A | xs]) do
    { number, rest } = parse_number(xs)
    [ {:Ref, number} | parse(rest) ]
  end

  def parse([:A, :B, :C | xs]) do
    { number, rest } = parse_number(xs)
    [ {:Slide, number} | parse(rest) ]
  end

  def parse([:A, :C, :A | xs]), do: [ :Dup     | parse(xs) ]
  def parse([:A, :C, :B | xs]), do: [ :Swap    | parse(xs) ]
  def parse([:A, :C, :C | xs]), do: [ :Discard | parse(xs) ]

  def parse([:B, :A, :A, :A | xs]), do: [ {:Infix, :Plus}   | parse(xs) ]
  def parse([:B, :A, :A, :B | xs]), do: [ {:Infix, :Minus}  | parse(xs) ]
  def parse([:B, :A, :A, :C | xs]), do: [ {:Infix, :Times}  | parse(xs) ]
  def parse([:B, :A, :B, :A | xs]), do: [ {:Infix, :Divide} | parse(xs) ]
  def parse([:B, :A, :B, :B | xs]), do: [ {:Infix, :Modulo} | parse(xs) ]

  def parse([:B, :B, :A | xs]), do: [ :Store    | parse(xs) ]
  def parse([:B, :B, :B | xs]), do: [ :Retrieve | parse(xs) ]

  def parse([:C, :A, :A | xs]) do
    { string, rest } = parse_string(xs)
    [ {:Label, string} | parse(rest) ]
  end

  def parse([:C, :A, :B | xs]) do
    { string, rest } = parse_string(xs)
    [ {:Call, string} | parse(rest) ]
  end

  def parse([:C, :A, :C | xs]) do
    { string, rest } = parse_string(xs)
    [ {:Jump, string} | parse(rest) ]
  end

  def parse([:C, :B, :A | xs]) do
    { string, rest } = parse_string(xs)
    [ {:If, :Zero, string} | parse(rest) ]
  end

  def parse([:C, :B, :B | xs]) do
    { string, rest } = parse_string(xs)
    [ {:If, :Negative, string} | parse(rest) ]
  end

  def parse([:C, :B, :C | xs]), do: [ :Return | parse(xs) ]
  def parse([:C, :C, :C | xs]), do: [ :End    | parse(xs) ]

  def parse([:B, :C, :A, :A | xs]), do: [ :OutputChar | parse(xs) ]
  def parse([:B, :C, :A, :B | xs]), do: [ :OutputNum  | parse(xs) ]
  def parse([:B, :C, :B, :A | xs]), do: [ :ReadChar   | parse(xs) ]
  def parse([:B, :C, :B, :B | xs]), do: [ :ReadNum    | parse(xs) ]

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