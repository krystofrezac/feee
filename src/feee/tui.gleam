import gleam/string
import gleam/string_builder
import teashop
import teashop/event
import teashop/command
import teashop/key
import feee/fs
import feee/tree
import feee/tui/viewport

type Flags {
  Flags(path: String)
}

type Model {
  Model(
    tree: tree.Node,
    cursor: Int,
    screen_height: Int,
    viewport: viewport.Model,
  )
}

fn init(flags: Flags) {
  #(
    Model(
      tree: fs.build_tree(flags.path),
      cursor: 0,
      screen_height: 1,
      viewport: viewport.create_model(),
    ),
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
      let new_cursor =
        model.cursor
        |> tree.move_down(model.tree)
      let new_viewport =
        model.viewport
        |> viewport.move_down(
          cursor_position: model.cursor,
          window_height: model.screen_height,
        )

      #(
        Model(..model, cursor: new_cursor, viewport: new_viewport),
        command.none(),
      )
    }
    event.Key(key.Char("k")) -> {
      let new_cursor =
        model.cursor
        |> tree.move_up()
      let new_viewport =
        model.viewport
        |> viewport.move_up(cursor_position: model.cursor)

      #(
        Model(..model, cursor: new_cursor, viewport: new_viewport),
        command.none(),
      )
    }

    event.Key(key.Char("o")) -> {
      let new_tree =
        model.cursor
        |> tree.toggle_open(model.tree)
      #(Model(..model, tree: new_tree), command.none())
    }

    event.Resize(height: height, ..) -> {
      #(Model(..model, screen_height: height), command.none())
    }
    _ -> #(model, command.none())
  }
}

fn render_tree_dir_children(
  children children: List(tree.Node),
  position position: Int,
  render render: fn(tree.Node, Int) -> String,
) -> String {
  case children {
    [] -> ""
    [head, ..tail] -> {
      let head_open_items = tree.count_open_items(head)
      let rendered_head = render(head, position)
      let rendered_tail =
        render_tree_dir_children(tail, position + head_open_items, render)
      rendered_head <> rendered_tail
    }
  }
}

fn render_tree_node(
  node node: tree.Node,
  cursor cursor: Int,
  position position: Int,
  indent indent: Int,
) -> String {
  let top_row =
    string_builder.new()
    |> string_builder.append(string.repeat("  ", indent))
    |> string_builder.append(case position == cursor {
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
      |> render_tree_dir_children(position + 1, fn(dir_node, dir_pos) {
        render_tree_node(dir_node, cursor, dir_pos, indent + 1)
      })
    _ -> ""
  }

  top_row
  |> string_builder.append(maybe_sub_items)
  |> string_builder.to_string
}

fn view(model: Model) {
  render_tree_node(
    node: model.tree,
    cursor: model.cursor,
    position: 0,
    indent: 0,
  )
  |> viewport.view(screen_height: model.screen_height, model: model.viewport)
}

pub fn run(path: String) {
  teashop.app(init, update, view)
  |> teashop.start(Flags(path: path))
}
