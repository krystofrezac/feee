import gleam/string
import gleam/int
import gleam/list

pub opaque type Model {
  Model(window_start_index: Int)
}

const offset = 5

pub fn create_model() {
  Model(window_start_index: 0)
}

pub fn move_up(
  model model: Model,
  cursor_position cursor_position: Int,
) -> Model {
  let viewport_should_move_up =
    cursor_position - offset < model.window_start_index
  case viewport_should_move_up {
    True -> Model(window_start_index: int.max(cursor_position - offset, 0))
    False -> model
  }
}

pub fn move_down(
  model model: Model,
  window_height window_height: Int,
  cursor_position cursor_position: Int,
) {
  let viewport_should_move_down =
    cursor_position + offset > model.window_start_index + window_height
  case viewport_should_move_down {
    True -> Model(window_start_index: cursor_position + offset - window_height)
    False -> model
  }
}

pub fn view(
  content content: String,
  model model: Model,
  screen_height screen_height: Int,
) {
  let rows =
    content
    |> string.split("\n")

  case list.length(rows) <= screen_height {
    True -> content
    False ->
      rows
      |> list.index_map(fn(row, index) { #(row, index) })
      |> list.filter_map(fn(indexed_row) {
        let #(row, index) = indexed_row

        case
          index >= model.window_start_index
          && index + 1 < model.window_start_index + screen_height
        {
          True -> Ok(row)
          False -> Error(Nil)
        }
      })
      |> string.join("\n")
  }
}
