import feee/interop
import feee/tui

pub fn main() {
  let path = case interop.get_argv() {
    [first_argv, ..] -> first_argv
    _ -> "."
  }

  tui.run(path)
}
