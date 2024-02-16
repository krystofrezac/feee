import gleeunit/should
import feee/tree

fn test_movement(
  expected expected_positions: List(Int),
  start start_position: Int,
  movement movement: fn(Int) -> Int,
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
    // 0
    tree.Dir(name: "root", open: True, children: [
      // 1
      tree.Dir(name: "a", open: True, children: [
        // 2
        tree.Dir(name: "a_a", open: True, children: [
          // 3
          tree.File(name: "a_a_a"),
          // 4
          tree.File(name: "a_a_b"),
        ]),
      ]),
      // 5
      tree.Dir(name: "b", open: False, children: [tree.File(name: "b_a")]),
      // 6
      tree.Dir(name: "c", open: True, children: [
        // 7
        tree.File(name: "c_a"),
        // 8
        tree.File(name: "c_b"),
      ]),
    ])

  [7, 6, 5, 4, 3, 2, 1, 0, 0]
  |> test_movement(start: 8, movement: tree.move_up)
}

pub fn move_down_test() {
  let tree =
    // 0
    tree.Dir(name: "root", open: True, children: [
      // 1
      tree.Dir(name: "a", open: True, children: [
        // 2
        tree.Dir(name: "a_a", open: True, children: [
          // 3
          tree.File(name: "a_a_a"),
          // 4
          tree.File(name: "a_a_b"),
        ]),
      ]),
      // 5
      tree.Dir(name: "b", open: False, children: [tree.File(name: "b_a")]),
      // 6
      tree.Dir(name: "c", open: True, children: [
        // 7
        tree.File(name: "c_a"),
        // 8
        tree.File(name: "c_b"),
      ]),
    ])

  let movement = fn(pointer: Int) { tree.move_down(pointer, tree) }

  [1, 2, 3, 4, 5, 6, 7, 8, 8]
  |> test_movement(start: 0, movement: movement)
}
