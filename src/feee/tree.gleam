import gleam/list
import gleam/int
import gleam/result

pub type Node {
  Dir(name: String, open: Bool, children: List(Node))
  File(name: String)
}

/// reversed - top level index is last
pub type Pointer =
  List(Int)

fn get_at_reversed(node: Node, pointer: Pointer) -> Result(Node, Nil) {
  case #(node, pointer) {
    #(Dir(children: children, ..), [index]) ->
      children
      |> list.at(index)
    #(Dir(children: children, ..), [index, ..rest]) ->
      children
      |> list.at(index)
      |> result.try(fn(sub_node) { get_at(sub_node, rest) })
    #(_, _) -> Error(Nil)
  }
}

fn get_at(node: Node, pointer: Pointer) -> Result(Node, Nil) {
  list.reverse(pointer)
  |> get_at_reversed(node, _)
}

pub fn move_up(pointer: Pointer, top_node: Node) -> Pointer {
  case pointer {
    [] -> []
    // go to same level
    [index, ..rest] if index > 0 -> {
      let new_pointer = [index - 1, ..rest]

      top_node
      |> get_at(new_pointer)
      |> result.replace_error(pointer)
      |> result.map(fn(current_node) {
        case current_node {
          Dir(open: True, children: children, ..) -> [
            list.length(children)
            |> int.subtract(1),
            ..new_pointer
          ]
          _ -> new_pointer
        }
      })
      |> result.unwrap_both
    }
    // go to parent, but not root
    [_, rest_head, ..rest_tail] -> {
      [rest_head, ..rest_tail]
    }
    // go to root
    _ -> pointer
  }
}
