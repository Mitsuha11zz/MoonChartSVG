// MoonChart CLI -- Demo Generator and Chart Rendering Tool
//
// Generates sample SVG charts for all supported chart types.
// Run with: `moon run cmd/main` from the project root.

fn main {
  print_usage()
  println("")
  println("Generating all demo charts...")
  println("")

  println("=== demo_bar.svg ===")
  println(@moonchart.generate_demo_barchart())
  println("=== demo_line.svg ===")
  println(@moonchart.generate_demo_linechart())
  println("=== demo_pie.svg ===")
  println(@moonchart.generate_demo_piechart())
  println("=== demo_scatter.svg ===")
  println(@moonchart.generate_demo_scatter())
  println("=== demo_radar.svg ===")
  println(@moonchart.generate_demo_radar())
  println("=== demo_area.svg ===")
  println(@moonchart.generate_demo_area())
  println("=== demo_dashboard.svg ===")
  println(@moonchart.generate_demo_dashboard())

  println("")
  println("Done! Redirect stdout with > to save SVGs to files.")
  println("  e.g. moon run cmd/main > all_charts.svg")
}

fn print_usage() -> Unit {
  println("MoonChart -- Pure MoonBit SVG Chart Generation Library")
  println("Version: 0.1.0")
  println("")
  println("Usage:")
  println("  moon run cmd/main              Generate all demo charts")
  println("  moon run cmd/main > out.svg    Save output to file")
  println("")
  println("Chart types included in demo:")
  println("  Bar chart, Line chart, Pie chart, Scatter plot,")
  println("  Radar chart, Area chart, and a composite Dashboard")
  println("")
  println("Library usage in code:")
  println("  let chart = BarChart::new()")
  println("    .title(\"My Chart\")")
  println("    .x_labels([...])")
  println("    .series(Series::new(\"Data\", [...]))")
  println("  let svg = chart.render()")
}
