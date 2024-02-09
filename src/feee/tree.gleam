import gleam/list
import gleam/io
import gleam/int
import gleam/result

pub type Node {
  Dir(name: String, open: Bool, children: List(Node))
  File(name: String)
}

/// reversed - top level index is last
pub type Pointer =
  List(Int)

pub fn move_up(pointer: Pointer, root_node: Node) -> Pointer {
  case pointer {
    // go to same level
    [index, ..rest] if index > 0 -> {
      let new_pointer = [index - 1, ..rest]

      new_pointer
      |> get_at(root_node)
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

pub fn move_down(pointer: Pointer, root_node: Node) -> Pointer {
  let current_node = get_at(pointer, root_node)

  case current_node {
    // go to children
    Ok(Dir(open: True, children: [_, ..], ..)) -> [0, ..pointer]
    Ok(_) -> {
      pointer
      |> get_down_same_level_pointer(root_node)
    }
    _ -> pointer
  }
}

fn get_at_reversed(pointer: Pointer, node: Node) -> Result(Node, Nil) {
  case #(node, pointer) {
    #(Dir(children: children, ..), [index]) ->
      children
      |> list.at(index)
    #(Dir(children: children, ..), [index, ..rest]) ->
      children
      |> list.at(index)
      |> result.try(fn(sub_node) { get_at_reversed(rest, sub_node) })
    #(_, _) -> Error(Nil)
  }
}

fn get_at(pointer: Pointer, root_node: Node) -> Result(Node, Nil) {
  list.reverse(pointer)
  |> get_at_reversed(root_node)
}

fn get_parent_node(pointer: Pointer, root_node: Node) -> Node {
  let parent_pointer = case pointer {
    [_, ..rest] -> rest
    _ -> pointer
  }

  parent_pointer
  |> get_at(root_node)
  |> result.replace_error(root_node)
  |> result.unwrap_both
}

fn get_down_same_level_pointer(pointer: Pointer, root_node: Node) -> Pointer {
  let parent = get_parent_node(pointer, root_node)

  case parent {
    // parent should always be dir
    File(..) -> pointer
    Dir(children: children, ..) -> {
      let parent_children_length = -1 + list.length(children)

      case pointer {
        // go to same level
        [current_level, ..parent_levels] if current_level < parent_children_length -> [
          current_level + 1,
          ..parent_levels
        ]
        // go to parent
        [_, ..rest] -> get_down_same_level_pointer(rest, root_node)
        [] -> pointer
      }
    }
  }
}
