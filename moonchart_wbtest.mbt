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

test "svg rect generation" {
  let r = rect(10.0, 20.0, 100.0, 50.0, "red")
  assert_eq(r.contains("<rect"), true)
  assert_eq(r.contains("x=\"10\""), true)
  assert_eq(r.contains("fill=\"red\""), true)
}

test "svg text generation" {
  let t = text(0.0, 0.0, "hello", 12, "middle")
  assert_eq(t.contains("<text"), true)
  assert_eq(t.contains("hello"), true)
  assert_eq(t.contains("font-size=\"12\""), true)
}

test "svg open and close" {
  let s = svg_open(800.0, 600.0)
  assert_eq(s.contains("<svg"), true)
  assert_eq(s.contains("800"), true)
  assert_eq(s.contains("600"), true)
}

test "y axis for positive data" {
  let layout = compute_y_axis(0.0, 187.0, 400.0, 40.0, 60.0)
  assert_eq(layout.y_min <= 0.0, true)
  assert_eq(layout.y_max >= 187.0, true)
  assert_eq(layout.step > 0.0, true)
}

test "y axis for zero range" {
  let layout = compute_y_axis(5.0, 5.0, 400.0, 40.0, 60.0)
  assert_eq(layout.y_min < 5.0, true)
  assert_eq(layout.y_max > 5.0, true)
}

test "y_to_svg maps min to bottom" {
  let y = y_to_svg(0.0, 0.0, 100.0, 400.0, 40.0, 60.0)
  assert_eq(y > 300.0, true)
}

test "y_to_svg maps max to top" {
  let y = y_to_svg(100.0, 0.0, 100.0, 400.0, 40.0, 60.0)
  assert_eq(y < 100.0, true)
}
