import gleam/io
import gleam/list
import gleam/string
import gleam/string_builder
import teashop
import teashop/event
import teashop/command
import teashop/key
import feee/fs
import feee/tree

pub type Model {
  Model(tree: tree.Node)
}

fn init(_) {
  #(
    Model(tree: fs.build_tree(".")),
    command.sequence([command.set_window_title("ahoj")]),
  )
  // command.enter_alt_screen(),
}

fn update(model: Model, event: event.Event(Nil)) {
  case event {
    event.Key(key.Char("q")) -> #(model, command.quit())
    _ -> #(model, command.none())
  }
}

fn get_node_icon(node: tree.Node) -> String {
  case node {
    tree.Dir(open: True, ..) -> "▼"
    tree.Dir(open: False, ..) -> "►"
    tree.File(..) -> "-"
  }
}

fn render_tree_node(node: tree.Node, indent: Int) -> String {
  let head =
    string_builder.new()
    |> string_builder.append(string.repeat("  ", indent))
    |> string_builder.append(get_node_icon(node))
    |> string_builder.append(" ")
    |> string_builder.append(node.name)
    |> string_builder.append("\n")

  let result = case node {
    tree.Dir(children: children, open: True, ..) ->
      head
      |> string_builder.append(
        children
        |> list.map(fn(item) { render_tree_node(item, indent + 1) })
        |> string.join(""),
      )
    _ -> head
  }
  result
  |> string_builder.to_string
}

fn view(model: Model) {
  render_tree_node(model.tree, 0)
}

pub fn main() {
  teashop.app(init, update, view)
  |> teashop.start(Nil)
}
