// Blackbox tests — end-to-end SVG output verification

test "full barchart workflow" {
  let chart = @MoonChartSVG.BarChart::new()
    .title("Monthly Revenue")
    .x_labels(["Jan", "Feb", "Mar", "Apr", "May", "Jun"])
    .series(@MoonChartSVG.Series::new("Product A", [120.0, 200.0, 150.0, 180.0, 220.0, 190.0]))
    .series(@MoonChartSVG.Series::new("Product B", [80.0, 130.0, 170.0, 140.0, 160.0, 200.0]))
    .width(800.0).height(400.0)
  let svg = chart.render()
  assert_eq!(svg.contains("<svg xmlns=\"http://www.w3.org/2000/svg\""), true)
  assert_eq!(svg.contains("</svg>"), true)
  assert_eq!(svg.contains("Monthly Revenue"), true)
  assert_eq!(svg.contains("Product A"), true)
  assert_eq!(svg.contains("Product B"), true)
}

test "full linechart workflow" {
  let chart = @MoonChartSVG.LineChart::new()
    .title("Quarterly Trend")
    .x_labels(["Q1", "Q2", "Q3", "Q4"])
    .series(@MoonChartSVG.Series::new("Growth", [50.0, 80.0, 120.0, 200.0]))
  let svg = chart.render()
  assert_eq!(svg.contains("<polyline"), true)
  assert_eq!(svg.contains("<circle"), true)
  assert_eq!(svg.contains("Quarterly Trend"), true)
}

test "full piechart workflow" {
  let chart = @MoonChartSVG.PieChart::new()
    .title("Market Share")
    .slice("Desktop", 55.0)
    .slice("Mobile", 35.0)
    .slice("Tablet", 10.0)
  let svg = chart.render()
  assert_eq!(svg.contains("<path"), true)
  assert_eq!(svg.contains("Desktop"), true)
}

test "svg output is well-formed" {
  let chart = @MoonChartSVG.BarChart::new()
    .title("Test")
    .x_labels(["A"])
    .series(@MoonChartSVG.Series::new("S", [1.0]))
  let svg = chart.render()
  assert_eq!(svg.contains("<svg"), true)
  assert_eq!(svg.has_suffix("</svg>"), true)
}
