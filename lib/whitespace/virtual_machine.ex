defmodule Whitespace.VirtualMachine do

  defrecord State,
    program: [],
    stack: [],
    call_stack: [],
    heap: HashDict.new,
    program_counter: 0

  def execute_instruction(vm_state, {:Push, n}) do
    vm_state.stack [ n | vm_state.stack ]
  end

  def execute_instruction(vm_state = State[stack: [ x | xs ]], :Dup) do
    vm_state.stack [ x, x | xs ]
  end

  def execute_instruction(vm_state, {:Ref, n}) do
    vm_state.stack [ Enum.at(vm_state.stack, n) | vm_state.stack ]
  end

  def execute_instruction(vm_state = State[stack: [ x | xs ]], {:Slide, n}) do
    vm_state.stack [ x | Enum.drop(xs, n) ]
  end

  def execute_instruction(vm_state = State[stack: [ x, y | xs ]], :Swap) do
    vm_state.stack [ y, x | xs ]
  end

  def execute_instruction(vm_state = State[stack: [ _ | xs ]], :Discard) do
    vm_state.stack xs
  end

  def execute_instruction(vm_state = State[stack: [ x, y | xs ]], {:Infix, :Plus}) do
    vm_state.stack [ y + x | xs ]
  end

  def execute_instruction(vm_state = State[stack: [ x, y | xs ]], {:Infix, :Minus}) do
    vm_state.stack [ y - x | xs ]
  end

  def execute_instruction(vm_state = State[stack: [ x, y | xs ]], {:Infix, :Times}) do
    vm_state.stack [ y * x | xs ]
  end

  def execute_instruction(vm_state = State[stack: [ x, y | xs ]], {:Infix, :Divide}) do
    vm_state.stack [ div(y, x) | xs ]
  end

  def execute_instruction(vm_state = State[stack: [ x, y | xs ]], {:Infix, :Modulo}) do
    vm_state.stack [ rem(y, x) | xs ]
  end

  def execute_instruction(vm_state, {:Label, _}) do
    vm_state
  end

  def execute_instruction(vm_state, {:Call, label}) do
    call_stack = [ vm_state.program_counter | vm_state.call_stack ]
    vm_state = vm_state.call_stack(call_stack)

    program_counter = find_label(label, vm_state.program)
    vm_state.program_counter program_counter
  end

  def execute_instruction(vm_state, {:Jump, label}) do
    find_label(label, vm_state.program)
      |> vm_state.program_counter
  end

  def execute_instruction(vm_state = State[stack: [ 0 | xs ]], {:If, :Zero, label}) do
    vm_state = vm_state.stack xs

    program_counter = find_label(label, vm_state.program)
    vm_state.program_counter program_counter
  end

  def execute_instruction(vm_state = State[stack: [ _ | xs ]], {:If, :Zero, _}) do
    vm_state.stack xs
  end

  def execute_instruction(vm_state = State[stack: [ x | xs ]], {:If, :Negative, label}) when x < 0 do
    vm_state = vm_state.stack xs

    program_counter = find_label(label, vm_state.program)
    vm_state.program_counter program_counter
  end

  def execute_instruction(vm_state = State[stack: [ _ | xs ]], {:If, :Negative, _}) do
    vm_state.stack(xs)
  end

  def execute_instruction(vm_state = State[call_stack: [ x | xs ]], :Return) do
    vm_state.call_stack(xs).program_counter(x)
  end

  def execute_instruction(vm_state = State[stack: [ val, addr | xs ]], :Store) do
    vm_state = vm_state.heap Dict.put(vm_state.heap, addr, val)
    vm_state.stack xs
  end

  def execute_instruction(vm_state = State[stack: [ addr | xs ]], :Retrieve) do
    value = Dict.fetch! vm_state.heap, addr
    vm_state.stack [ value | xs ]
  end

  def execute_instruction(_, :End) do
    { :ok }
  end

  defp find_label(label, [ {:Label, label} | _]), do: 0
  defp find_label(label, [ _ | xs]), do: 1 + find_label(label, xs)
end