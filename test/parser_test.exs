defmodule ParserTest do
  use ExUnit.Case

  import Whitespace.Parser

  test "tokenize" do
    assert tokenize(String.codepoints "")   == []
    assert tokenize(String.codepoints "\s") == [:A]
    assert tokenize(String.codepoints "\t") == [:B]
    assert tokenize(String.codepoints "\n") == [:C]
    assert tokenize(String.codepoints "comment") == []
    assert tokenize(String.codepoints "this is a sentence") == [:A, :A, :A]
    assert tokenize(String.codepoints "\s\t\ncomment\n\t\s") == [:A, :B, :C, :C, :B, :A]
  end

  test "parse" do
    assert parse [:A, :A, :A, :A, :C]     == [:Push, 1]
    assert parse [:A, :B, :A, :A, :A, :C] == [:Ref, 1]
    assert parse [:A, :B, :C, :A, :A, :C] == [:Slide, 1]

    assert parse [:A, :C, :A] == [:Dup]
    assert parse [:A, :C, :B] == [:Swap]
    assert parse [:A, :C, :C] == [:Discard]

    assert parse [:B, :A, :A, :A] == [:InfixPlus]
    assert parse [:B, :A, :A, :B] == [:InfixMinus]
    assert parse [:B, :A, :A, :C] == [:InfixTimes]
    assert parse [:B, :A, :B, :A] == [:InfixDivide]
    assert parse [:B, :A, :B, :B] == [:InfixModulo]

    assert parse [:B, :B, :A] == [:Store]
    assert parse [:B, :B, :B] == [:Retrieve]

    assert parse [:C, :A, :A, :A, :C] == [:Label, "\s"]
    assert parse [:C, :A, :B, :A, :C] == [:Call, "\s"]
    assert parse [:C, :A, :C, :A, :C] == [:Jump, "\s"]
    assert parse [:C, :B, :A, :A, :C] == [:IfZero, "\s"]
    assert parse [:C, :B, :B, :A, :C] == [:IfNegative, "\s"]

    assert parse [:C, :B, :C]     == [:Return]
    assert parse [:C, :C, :C]     == [:End]

    assert parse [:B, :A, :A, :A] == [:OutputChar]
    assert parse [:B, :C, :A, :B] == [:OutputNum]
    assert parse [:B, :C, :B, :A] == [:ReadChar]
    assert parse [:B, :C, :B, :B] == [:ReadNum]
  end
end