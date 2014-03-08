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
    assert parse ([:A, :A, :A, :B, :C])     == [:Push, 1]
    assert parse ([:A, :B, :A, :A, :B, :C]) == [:Ref, 1]
    assert parse ([:A, :B, :C, :A, :B, :C]) == [:Slide, 1]

    assert parse ([:A, :C, :A]) == [:Dup]
    assert parse ([:A, :C, :B]) == [:Swap]
    assert parse ([:A, :C, :C]) == [:Discard]

    assert parse([:B, :A, :A, :A]) == [:InfixPlus]
    assert parse([:B, :A, :A, :B]) == [:InfixMinus]
    assert parse([:B, :A, :A, :C]) == [:InfixTimes]
    assert parse([:B, :A, :B, :A]) == [:InfixDivide]
    assert parse([:B, :A, :B, :B]) == [:InfixModulo]

    assert parse([:B, :B, :A]) == [:Store]
    assert parse([:B, :B, :B]) == [:Retrieve]

    assert parse([:C, :A, :A, :A, :C]) == [:Label, "\s"]
    assert parse([:C, :A, :B, :A, :C]) == [:Call, "\s"]
    assert parse([:C, :A, :C, :A, :C]) == [:Jump, "\s"]
    assert parse([:C, :B, :A, :A, :C]) == [:IfZero, "\s"]
    assert parse([:C, :B, :B, :A, :C]) == [:IfNegative, "\s"]

    assert parse([:C, :B, :C])     == [:Return]
    assert parse([:C, :C, :C])     == [:End]

    assert parse([:B, :A, :A, :A]) == [:OutputChar]
    assert parse([:B, :C, :A, :B]) == [:OutputNum]
    assert parse([:B, :C, :B, :A]) == [:ReadChar]
    assert parse([:B, :C, :B, :B]) == [:ReadNum]
  end

  test "parse_number" do
    assert parse_number([:A, :C]) == {0, []}
    assert parse_number([:A, :A, :C]) == {0, []}
    assert parse_number([:A, :B, :C]) == {1, []}
    assert parse_number([:B, :B, :C]) == {-1, []}
    assert parse_number([:A, :A, :A, :C]) == {0, []}
    assert parse_number([:A, :A, :B, :C]) == {1, []}
    assert parse_number([:A, :B, :A, :C]) == {2, []}
    assert parse_number([:A, :B, :B, :C]) == {3, []}
    assert parse_number([:B, :A, :A, :C]) == {0, []}
    assert parse_number([:B, :A, :B, :C]) == {-1, []}
    assert parse_number([:B, :B, :A, :C]) == {-2, []}
    assert parse_number([:B, :B, :B, :C]) == {-3, []}

    assert parse_number([:C, :A, :B, :C]) == {0, [:A, :B, :C]}
  end

  test "parse_string" do
    assert parse_string([:C]) == {"", []}
    assert parse_string([:A, :C]) == {"\s", []}
    assert parse_string([:B, :C]) == {"\t", []}
    assert parse_string([:A, :B, :C]) == {"\s\t", []}
    assert parse_string([:B, :A, :C]) == {"\t\s", []}

    assert parse_string([:C, :A, :B, :C])== {"", [:A, :B, :C]}
  end
end