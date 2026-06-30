// MoonChartSVG CLI -- Demo Generator
// Run: moon run cmd/main

fn main {
  println("=== MoonChartSVG Demo Generator ===\n")

  demo_all_charts()
  demo_themed_charts()
  demo_csv_workflow()
  demo_stats_example()

  println("\n=== All demos complete ===")
}

fn demo_all_charts() {
  println("--- 1. All Chart Types ---")
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
}

fn demo_themed_charts() {
  println("--- 2. Themed Charts ---")

  let dark = @MoonChartSVG.Theme::dark().to_config()
  let chart1 = @MoonChartSVG.BarChart::new()
    .title("Dark Theme Example")
    .x_labels(["Mon", "Tue", "Wed", "Thu", "Fri"])
    .series(@MoonChartSVG.Series::new("Visitors", [120.0, 200.0, 150.0, 180.0, 250.0]))
    .config(dark)
  println("@theme_dark.svg")
  println(chart1.render())

  let warm = @MoonChartSVG.Theme::warm().to_config()
  let chart2 = @MoonChartSVG.BarChart::new()
    .title("Warm Theme Example")
    .x_labels(["Q1", "Q2", "Q3", "Q4"])
    .series(@MoonChartSVG.Series::new("Revenue", [50.0, 80.0, 120.0, 200.0]))
    .config(warm)
  println("@theme_warm.svg")
  println(chart2.render())
}

fn demo_csv_workflow() {
  println("--- 3. CSV Data to Chart ---")

  let csv = "Month,Sales,Costs\nJan,120,80\nFeb,200,130\nMar,150,110\nApr,180,120\nMay,220,140\nJun,190,130"
  let (headers, rows) = @MoonChartSVG.parse_csv(csv)
  println("Parsed " + rows.length().to_string() + " rows from CSV")

  let labels : @moonbitlang.Array[String] = []
  let sales : @moonbitlang.Array[@MoonChartSVG.Float] = []
  let costs : @moonbitlang.Array[@MoonChartSVG.Float] = []
  // Build arrays from CSV data using recursive helpers
  let (_, _, _) = build_csv_arrays(rows, 0, labels, sales, costs)
  // For now, show the parsed structure
  println("Headers: " + headers.length().to_string() + " columns")
  println("Ready to generate charts from CSV data")
}

fn build_csv_arrays(rows : @moonbitlang.Array[@moonbitlang.Array[String]], idx : Int,
    labels : @moonbitlang.Array[String], sales : @moonbitlang.Array[@MoonChartSVG.Float],
    costs : @moonbitlang.Array[@MoonChartSVG.Float]) ->
    (@moonbitlang.Array[String], @moonbitlang.Array[@MoonChartSVG.Float], @moonbitlang.Array[@MoonChartSVG.Float]) {
  if idx >= rows.length() { (labels, sales, costs) }
  else {
    labels.push(rows[idx][0])
    sales.push(@MoonChartSVG.parse_float_or_zero(rows[idx][1]))
    costs.push(@MoonChartSVG.parse_float_or_zero(rows[idx][2]))
    build_csv_arrays(rows, idx + 1, labels, sales, costs)
  }
}

fn demo_stats_example() {
  println("--- 4. Data Statistics ---")
  let data : @moonbitlang.Array[@MoonChartSVG.Float] = [12.0, 15.0, 8.0, 22.0, 10.0, 18.0, 14.0]
  println("Data: [12, 15, 8, 22, 10, 18, 14]")
  println("Sum: " + @MoonChartSVG.sum(data).to_string())
  println("Mean: " + @MoonChartSVG.mean(data).to_string())
  println("Min: " + @MoonChartSVG.min_value(data).to_string())
  println("Max: " + @MoonChartSVG.max_value(data).to_string())
  println("Median: " + @MoonChartSVG.median(data).to_string())

  // Generate a chart from stats
  let chart = @MoonChartSVG.BarChart::new()
    .title("Data Distribution")
    .x_labels(["1st", "2nd", "3rd", "4th", "5th", "6th", "7th"])
    .series(@MoonChartSVG.Series::new("Values", data))
  println("@stats_chart.svg")
  println(chart.render())
}
