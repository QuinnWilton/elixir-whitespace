defmodule Whitespace.VirtualMachineTest do
  use ExUnit.Case

  import Whitespace.VirtualMachine
  import Whitespace.VirtualMachine.State

  test "execute_instruction" do
    vm_state = Whitespace.VirtualMachine.State.new(
      program: [{:Push, 5}, {:Label, "foo"}],
      stack: [1, 2, 3],
      call_stack: [10],
      heap: HashDict.new([{1, 2}, {2, 3}]),
      program_counter: 0
    )

    assert execute_instruction(vm_state, {:Push, 0}) ==
      vm_state.stack([0, 1, 2, 3])

    assert execute_instruction(vm_state, :Dup) ==
      vm_state.stack([1, 1, 2, 3])

    assert execute_instruction(vm_state, {:Ref, 0}) ==
      vm_state.stack([1, 1, 2, 3])

    assert execute_instruction(vm_state, {:Ref, 1}) ==
      vm_state.stack([2, 1, 2, 3])

    assert execute_instruction(vm_state, {:Slide, 0}) ==
      vm_state.stack([1, 2, 3])

    assert execute_instruction(vm_state, {:Slide, 1}) ==
      vm_state.stack([1, 3])

    assert execute_instruction(vm_state, {:Slide, 2}) ==
      vm_state.stack([1])

    assert execute_instruction(vm_state, :Swap) ==
      vm_state.stack([2, 1, 3])

    assert execute_instruction(vm_state, :Discard) ==
      vm_state.stack([2, 3])

    assert execute_instruction(vm_state, {:Infix, :Plus}) ==
      vm_state.stack([3, 3])

    assert execute_instruction(vm_state, {:Infix, :Minus}) ==
      vm_state.stack([1, 3])

    assert execute_instruction(vm_state, {:Infix, :Times}) ==
      vm_state.stack([2, 3])

    assert execute_instruction(vm_state, {:Infix, :Divide}) ==
      vm_state.stack([2, 3])

    assert execute_instruction(vm_state, {:Infix, :Modulo}) ==
      vm_state.stack([0, 3])

    assert execute_instruction(vm_state, {:Label, "foo"}) ==
      vm_state

    assert execute_instruction(vm_state, {:Call, "foo"}) ==
      vm_state.call_stack([0, 10]).program_counter(1)

    assert execute_instruction(vm_state, {:Jump, "foo"}) ==
      vm_state.program_counter(1)

    assert execute_instruction(vm_state, {:If, :Zero, "foo"}) ==
      vm_state.stack([2,3])

    assert execute_instruction(vm_state.stack([0]), {:If, :Zero, "foo"}) ==
      vm_state.stack([]).program_counter(1)

    assert execute_instruction(vm_state, {:If, :Negative, "foo"}) ==
      vm_state.stack([2,3])

    assert execute_instruction(vm_state.stack([-1]), {:If, :Negative, "foo"}) ==
      vm_state.stack([]).program_counter(1)

    assert execute_instruction(vm_state, :Return) ==
      vm_state.call_stack([]).program_counter(10)

    assert execute_instruction(vm_state, :Store) ==
      vm_state.heap(HashDict.new([{1, 2}, {2, 1}])).stack([3])

    assert execute_instruction(vm_state, :Retrieve) ==
      vm_state.stack([2, 2, 3])

    assert execute_instruction(vm_state, :End) == { :ok }
  end
end