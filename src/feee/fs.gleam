import gleam/list
import gleam/string
import gleam/order
import feee/tree
import feee/interop

fn build_tree_level(path: String) -> List(tree.Node) {
  interop.read_dir(path)
  |> list.sort(fn(a, b) {
    case #(a, b) {
      #(interop.FsItem(is_file: True, ..), interop.FsItem(is_file: False, ..)) ->
        order.Gt
      #(interop.FsItem(is_file: False, ..), interop.FsItem(is_file: True, ..)) ->
        order.Lt
      #(_, _) -> string.compare(a.name, b.name)
    }
  })
  |> list.map(fn(item) {
    case item {
      interop.FsItem(name: name, is_file: True) -> tree.File(name: name)
      interop.FsItem(name: name, is_file: False) ->
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
