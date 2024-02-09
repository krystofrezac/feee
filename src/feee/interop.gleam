import gleam/list
import gleam/javascript/array

pub type FsItem {
  FsItem(name: String, is_file: Bool)
}

@external(javascript, "../interop.ffi.mjs", "readDir")
fn read_dir_external(path: String) -> array.Array(#(String, Bool))

pub fn read_dir(path: String) -> List(FsItem) {
  read_dir_external(path)
  |> array.to_list
  |> list.map(fn(item) {
    let #(name, is_file) = item
    FsItem(name: name, is_file: is_file)
  })
}

@external(javascript, "../interop.ffi.mjs", "getArgv")
fn get_argv_external() -> array.Array(String)

pub fn get_argv() -> List(String) {
  get_argv_external()
  |> array.to_list
}
