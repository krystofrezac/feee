import gleeunit/should
import feee/tree

pub fn move_up_test() {
  let tree =
    tree.Dir(name: "root", open: True, children: [
      // [0]
      tree.Dir(name: "a", open: True, children: [
        // [0, 0]
        tree.File(name: "a_a"),
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

  let pointer: tree.Pointer = [1, 2]

  // go to same level file
  let pointer =
    pointer
    |> tree.move_up(tree)
  pointer
  |> should.equal([0, 2])

  // go to parent
  let pointer =
    pointer
    |> tree.move_up(tree)
  pointer
  |> should.equal([2])

  // go to same level closed dir
  let pointer =
    pointer
    |> tree.move_up(tree)
  pointer
  |> should.equal([1])

  // go to same level opened dir
  let pointer =
    pointer
    |> tree.move_up(tree)
  pointer
  |> should.equal([0, 0])

  // go to parent
  let pointer =
    pointer
    |> tree.move_up(tree)
  pointer
  |> should.equal([0])

  // go to top
  let pointer =
    pointer
    |> tree.move_up(tree)
  pointer
  |> should.equal([0])
}
