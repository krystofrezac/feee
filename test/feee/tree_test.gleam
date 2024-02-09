import gleeunit/should
import feee/tree

fn test_movement(
  expected expected_positions: List(tree.Pointer),
  start start_position: tree.Pointer,
  movement movement: fn(tree.Pointer) -> tree.Pointer,
) {
  case expected_positions {
    [] -> Nil
    [expected, ..expected_rest] -> {
      let new_position = movement(start_position)
      new_position
      |> should.equal(expected)

      test_movement(
        expected: expected_rest,
        start: new_position,
        movement: movement,
      )
    }
  }
}

pub fn move_up_test() {
  let tree =
    tree.Dir(name: "root", open: True, children: [
      // [0]
      tree.Dir(name: "a", open: True, children: [
        // [0, 0]
        tree.Dir(name: "a_a", open: True, children: [
          // [0, 0, 0]
          tree.File(name: "a_a_a"),
          // [1, 0, 0]
          tree.File(name: "a_a_b"),
        ]),
      ]),
      // [1]
      tree.Dir(name: "b", open: False, children: [
        // [0, 1]
        tree.File(name: "b_a"),
      ]),
      // [2]
      tree.Dir(name: "c", open: True, children: [
        // [0, 2]
        tree.File(name: "c_a"),
        // [1, 2]
        tree.File(name: "c_b"),
      ]),
    ])

  let movement = fn(pointer: tree.Pointer) { tree.move_up(pointer, tree) }

  [[0, 2], [2], [1], [1, 0, 0], [0, 0, 0], [0, 0], [0], [0]]
  |> test_movement(start: [1, 2], movement: movement)
}

pub fn move_down_test() {
  let tree =
    tree.Dir(name: "root", open: True, children: [
      // [0]
      tree.Dir(name: "a", open: True, children: [
        // [0, 0]
        tree.Dir(name: "a_a", open: True, children: [
          // [0, 0, 0]
          tree.File(name: "a_a_a"),
          // [1, 0, 0]
          tree.File(name: "a_a_b"),
        ]),
      ]),
      // [1]
      tree.Dir(name: "b", open: False, children: [
        // [0, 1]
        tree.File(name: "b_a"),
      ]),
      // [2]
      tree.Dir(name: "c", open: True, children: [
        // [0, 2]
        tree.File(name: "c_a"),
        // [1, 2]
        tree.File(name: "c_b"),
      ]),
    ])

  let movement = fn(pointer: tree.Pointer) { tree.move_down(pointer, tree) }

  [[0, 0], [0, 0, 0], [1, 0, 0], [1], [2], [0, 2], [1, 2], [1, 2]]
  |> test_movement(start: [0], movement: movement)
}
