defmodule Whitespace.Parser do

  def tokenize([]), do: []
  def tokenize(["\s" | xs]), do: [ :A | tokenize xs ]
  def tokenize(["\t" | xs]), do: [ :B | tokenize xs ]
  def tokenize(["\n" | xs]), do: [ :C | tokenize xs ]
  def tokenize([_ | xs]),    do: tokenize(xs)
end