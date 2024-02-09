import gleam/list
import gleam/string
import gleam/string_builder
import teashop
import teashop/event
import teashop/command
import teashop/key
import feee/fs
import feee/tree

 type Flags {
  Flags(path: String)
}

 type Model {
  Model(tree: tree.Node, active_file: tree.Pointer)
}

fn init(flags: Flags) {
  #(
    Model(tree: fs.build_tree(flags.path), active_file: [0]),
    command.sequence([
      command.set_window_title("feee"),
      command.enter_alt_screen(),
    ]),
  )
}

fn update(model: Model, event: event.Event(Nil)) {
  case event {
    event.Key(key.Char("q")) -> #(model, command.quit())

    event.Key(key.Char("j")) -> {
      let new_active_file =
        model.active_file
        |> tree.move_down(model.tree)

      #(Model(..model, active_file: new_active_file), command.none())
    }
    event.Key(key.Char("k")) -> {
      let new_active_file =
        model.active_file
        |> tree.move_up(model.tree)

      #(Model(..model, active_file: new_active_file), command.none())
    }

    event.Key(key.Char("o")) -> {
      let new_tree =
        model.active_file
        |> tree.toggle_open(model.tree)

      #(Model(..model, tree: new_tree), command.none())
    }

    _ -> #(model, command.none())
  }
}

fn render_tree_node(
  node node: tree.Node,
  active_file active_file: tree.Pointer,
  position position: tree.Pointer,
  indent indent: Int,
) -> String {
  let top_row =
    string_builder.new()
    |> string_builder.append(string.repeat("  ", indent))
    |> string_builder.append(case position == active_file {
      True -> "x"
      False -> " "
    })
    |> string_builder.append(case node {
      tree.Dir(open: True, ..) -> "▼"
      tree.Dir(open: False, ..) -> "►"
      tree.File(..) -> "-"
    })
    |> string_builder.append(" ")
    |> string_builder.append(node.name)
    |> string_builder.append("\n")

  let maybe_sub_items = case node {
    tree.Dir(children: children, open: True, ..) ->
      children
      |> list.index_map(fn(item, index) {
        render_tree_node(
          node: item,
          active_file: active_file,
          position: [index, ..position],
          indent: indent + 1,
        )
      })
      |> string.join("")
    _ -> ""
  }

  top_row
  |> string_builder.append(maybe_sub_items)
  |> string_builder.to_string
}

fn view(model: Model) {
  render_tree_node(
    node: model.tree,
    active_file: model.active_file,
    position: [],
    indent: 0,
  )
}

pub fn run(path: String){
	
  teashop.app(init, update, view)
  |> teashop.start(Flags(path: path))
}
