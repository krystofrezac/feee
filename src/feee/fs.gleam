import gleam/list
import gleam/string
import gleam/order
import gleam/javascript/array
import feee/tree

type File {
  File(name: String)
  Dir(name: String)
}

@external(javascript, "../interop.ffi.mjs", "readDir")
fn read_dir_external(path: String) -> array.Array(#(String, Bool))

fn read_dir(path: String) -> List(File) {
  read_dir_external(path)
  |> array.to_list
  |> list.map(fn(item) {
    case item {
      #(name, True) -> File(name)
      #(name, False) -> Dir(name)
    }
  })
}

fn build_tree_level(path: String) -> List(tree.Node) {
  read_dir(path)
  |> list.sort(fn(a, b) {
    case #(a, b) {
      #(Dir(_), File(_)) -> order.Lt
      #(File(_), Dir(_)) -> order.Gt
      #(_, _) -> string.compare(a.name, b.name)
    }
  })
  |> list.map(fn(item) {
    case item {
      File(name) -> tree.File(name: name)
      Dir(name) ->
        tree.Dir(
          name: name,
          open: False,
          children: build_tree_level(path <> "/" <> name),
        )
    }
  })
}

pub fn build_tree(path: String) -> tree.Node {
  build_tree_level(path)
  |> tree.Dir(name: "root", open: True)
}
