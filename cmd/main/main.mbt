// MoonChartSVG CLI -- Demo Generator
// Run: moon run cmd/main

fn main {
  println("=== MoonChartSVG Demo Generator ===\n")

  println("--- 1. All Chart Demos ---")
  println("@demo_bar.svg")
  println(@MoonChartSVG.generate_demo_barchart())
  println("@demo_line.svg")
  println(@MoonChartSVG.generate_demo_linechart())
  println("@demo_pie.svg")
  println(@MoonChartSVG.generate_demo_piechart())
  println("@demo_scatter.svg")
  println(@MoonChartSVG.generate_demo_scatter())
  println("@demo_radar.svg")
  println(@MoonChartSVG.generate_demo_radar())
  println("@demo_area.svg")
  println(@MoonChartSVG.generate_demo_area())
  println("@demo_dashboard.svg")
  println(@MoonChartSVG.generate_demo_dashboard())

  println("\n--- 2. Theme Examples ---")
  let dark_cfg = @MoonChartSVG.ChartConfig::default()
  let chart = @MoonChartSVG.BarChart::new()
    .title("Theme Example")
    .x_labels(["A", "B", "C", "D", "E"])
    .series(@MoonChartSVG.Series::new("Values", [10.0, 25.0, 15.0, 30.0, 20.0]))
    .config(dark_cfg)
  println("@theme_chart.svg")
  println(chart.render())

  println("\n--- 3. CSV Data Demo ---")
  let csv = "Month,Sales\nJan,120\nFeb,200\nMar,150"
  let (headers, rows) = @MoonChartSVG.parse_csv(csv)
  println("Parsed " + rows.length().to_string() + " rows from CSV")

  println("\n=== All demos complete ===")
}
