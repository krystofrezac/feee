import gleam/list
import gleam/int

pub type Node {
  Dir(name: String, open: Bool, children: List(Node))
  File(name: String)
}

pub fn move_up(cursor: Int) -> Int {
  case cursor {
    0 -> 0
    _ -> cursor - 1
  }
}

pub fn move_down(cursor: Int, root_node: Node) -> Int {
  let open_items_count = count_open_items(root_node)
  let max_cursor = open_items_count - 1

  case cursor >= max_cursor {
    True -> cursor
    False -> cursor + 1
  }
}

pub fn count_open_items(node: Node) -> Int {
  case node {
    Dir(children: children, open: True, ..) ->
      children
      |> list.map(count_open_items)
      |> int.sum
      |> int.add(1)
    _ -> 1
  }
}

fn toggle_open_dir(
  cursor: Int,
  children: List(Node),
  toggle_open: fn(Int, Node) -> Node,
) -> List(Node) {
  case children {
    [] -> []
    [head, ..tail] -> {
      let head_open_items = count_open_items(head)
      let toggled_head = toggle_open(cursor, head)
      let toggled_tail =
        toggle_open_dir(cursor - head_open_items, tail, toggle_open)
      [toggled_head, ..toggled_tail]
    }
  }
}

pub fn toggle_open(cursor: Int, node: Node) -> Node {
  case #(cursor, node) {
    #(0, Dir(open: open, name: name, children: children)) ->
      Dir(open: !open, name: name, children: children)
    #(_, Dir(children: children, open: open, name: name)) -> {
      Dir(
        children: toggle_open_dir(cursor - 1, children, toggle_open),
        open: open,
        name: name,
      )
    }
    _ -> node
  }
}
