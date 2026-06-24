// Whitebox tests run within the package scope.
// Use them to validate internal helpers or invariants.
// Keep them focused; public behavior belongs in `_test.mbt`.

test "Series creation" {
  let s = Series::new("test", [1.0, 2.0, 3.0])
  assert_eq!(s.name, "test")
  assert_eq!(s.values.length(), 3)
  assert_eq!(s.values[0], 1.0)
}

test "Slice creation" {
  let sl = Slice::new("A", 42.0)
  assert_eq!(sl.name, "A")
  assert_eq!(sl.value, 42.0)
}

test "color cycles through palette" {
  assert_eq!(get_color(0), "#4E79A7")
  assert_eq!(get_color(1), "#F28E2B")
  assert_eq!(get_color(10), "#4E79A7")
  assert_eq!(get_color(9), "#BAB0AC")
}
