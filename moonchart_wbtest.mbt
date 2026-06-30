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

test "legend with single name returns empty" {
  let result = render_legend(["Only"], 800.0, 380.0, ChartConfig::default())
  assert_eq(result, "")
}

test "legend with multiple names returns items" {
  let result = render_legend(["A", "B", "C"], 800.0, 380.0, ChartConfig::default())
  assert_eq(result.contains("rect"), true)
  assert_eq(result.contains("A"), true)
  assert_eq(result.contains("B"), true)
  assert_eq(result.contains("C"), true)
}

test "barchart basic render" {
  let chart = BarChart::new()
    .title("Test")
    .x_labels(["A", "B", "C"])
    .series(Series::new("S1", [10.0, 20.0, 30.0]))
    .width(600.0).height(300.0)
  let svg = chart.render()
  assert_eq(svg.contains("<svg"), true)
  assert_eq(svg.contains("</svg>"), true)
  assert_eq(svg.contains("Test"), true)
  assert_eq(svg.contains("<rect"), true)
}

test "barchart multi series" {
  let chart = BarChart::new()
    .x_labels(["Jan", "Feb"])
    .series(Series::new("A", [10.0, 20.0]))
    .series(Series::new("B", [30.0, 15.0]))
  let svg = chart.render()
  assert_eq(svg.contains("A"), true)
  assert_eq(svg.contains("B"), true)
  assert_eq(svg.contains("Jan"), true)
}

test "barchart empty data" {
  let chart = BarChart::new().title("Empty")
  let svg = chart.render()
  assert_eq(svg.contains("<svg"), true)
  assert_eq(svg.contains("</svg>"), true)
}

test "linechart basic render" {
  let chart = LineChart::new()
    .title("Trend")
    .x_labels(["Q1", "Q2", "Q3", "Q4"])
    .series(Series::new("Revenue", [50.0, 80.0, 120.0, 200.0]))
  let svg = chart.render()
  assert_eq(svg.contains("<svg"), true)
  assert_eq(svg.contains("<polyline"), true)
  assert_eq(svg.contains("Trend"), true)
}

test "linechart multi series" {
  let chart = LineChart::new()
    .x_labels(["A", "B"])
    .series(Series::new("X", [1.0, 2.0]))
    .series(Series::new("Y", [3.0, 4.0]))
  let svg = chart.render()
  assert_eq(svg.contains("X"), true)
  assert_eq(svg.contains("Y"), true)
}

test "linechart single point" {
  let chart = LineChart::new()
    .x_labels(["A"])
    .series(Series::new("Only", [5.0]))
  let svg = chart.render()
  assert_eq(svg.contains("<circle"), true)
}

test "piechart basic render" {
  let chart = PieChart::new()
    .title("Market")
    .slice("A", 40.0)
    .slice("B", 35.0)
    .slice("C", 25.0)
  let svg = chart.render()
  assert_eq(svg.contains("<svg"), true)
  assert_eq(svg.contains("<path"), true)
  assert_eq(svg.contains("Market"), true)
  assert_eq(svg.contains("A"), true)
}

test "piechart single slice" {
  let chart = PieChart::new().slice("Only", 100.0)
  let svg = chart.render()
  assert_eq(svg.contains("<path"), true)
}

test "piechart empty" {
  let chart = PieChart::new()
  let svg = chart.render()
  assert_eq(svg.contains("<svg"), true)
  assert_eq(svg.contains("</svg>"), true)
}

test "areachart basic render" {
  let chart = AreaChart::new()
    .title("Growth")
    .x_labels(["Q1", "Q2", "Q3", "Q4"])
    .series(Series::new("Revenue", [50.0, 80.0, 120.0, 200.0]))
  let svg = chart.render()
  assert_eq(svg.contains("<svg"), true)
  assert_eq(svg.contains("<polygon"), true)
  assert_eq(svg.contains("<polyline"), true)
  assert_eq(svg.contains("Growth"), true)
}

test "areachart multi series" {
  let chart = AreaChart::new()
    .x_labels(["A", "B", "C"])
    .series(Series::new("X", [10.0, 20.0, 15.0]))
    .series(Series::new("Y", [5.0, 25.0, 10.0]))
  let svg = chart.render()
  assert_eq(svg.contains("X"), true)
  assert_eq(svg.contains("Y"), true)
}

test "barchart with custom config" {
  let cfg = ChartConfig::{ colors: ["#FF0000", "#00FF00"], show_grid: false, title_font_size: 20, axis_font_size: 10, legend_font_size: 9 }
  let chart = BarChart::new()
    .title("Test")
    .x_labels(["A", "B"])
    .series(Series::new("S1", [10.0, 20.0]))
    .series(Series::new("S2", [30.0, 15.0]))
    .config(cfg)
  let svg = chart.render()
  assert_eq!(svg.contains("#FF0000"), true)
  assert_eq!(svg.contains("#00FF00"), true)
  assert_eq!(svg.contains("font-size=\"20\""), true)
}

test "linechart with custom colors" {
  let cfg = ChartConfig::default()
  let cfg2 = ChartConfig::{ ..cfg, colors: ["#123456"] }
  let chart = LineChart::new()
    .x_labels(["A", "B"])
    .series(Series::new("X", [1.0, 2.0]))
    .config(cfg2)
  let svg = chart.render()
  assert_eq!(svg.contains("#123456"), true)
}

test "scatter basic render" {
  let chart = ScatterChart::new()
    .title("Correlation")
    .x_label("Height")
    .y_label("Weight")
    .series(Series::new("Group A", [1.0, 2.0, 3.0, 4.0, 5.0]))
  let svg = chart.render()
  assert_eq(svg.contains("<svg"), true)
  assert_eq(svg.contains("<circle"), true)
  assert_eq(svg.contains("Correlation"), true)
}

test "radar basic render" {
  let chart = RadarChart::new()
    .title("Skills")
    .axis_labels(["Speed", "Power", "Accuracy", "Defense", "Stamina"])
    .series(Series::new("Player 1", [80.0, 70.0, 90.0, 60.0, 85.0]))
  let svg = chart.render()
  assert_eq(svg.contains("<svg"), true)
  assert_eq(svg.contains("<polygon"), true)
  assert_eq(svg.contains("Speed"), true)
}

// CSV Reader tests

test "csv parse simple" {
  let (headers, rows) = parse_csv("Name,Value\nA,10\nB,20")
  assert_eq!(headers[0], "Name")
  assert_eq!(headers[1], "Value")
  assert_eq!(rows.length(), 2)
  assert_eq!(rows[0][0], "A")
  assert_eq!(rows[0][1], "10")
}

test "csv parse single row" {
  let (headers, rows) = parse_csv("X,Y,Z\n1,2,3")
  assert_eq!(headers.length(), 3)
  assert_eq!(rows.length(), 1)
  assert_eq!(rows[0][0], "1")
  assert_eq!(rows[0][1], "2")
  assert_eq!(rows[0][2], "3")
}

test "csv parse empty content" {
  let (headers, rows) = parse_csv("")
  assert_eq!(headers.length(), 0)
  assert_eq!(rows.length(), 0)
}

test "csv parse header only" {
  let (headers, rows) = parse_csv("A,B,C")
  assert_eq!(headers.length(), 3)
  assert_eq!(rows.length(), 0)
}

test "csv parse with newline at end" {
  let (headers, rows) = parse_csv("Col1,Col2\nv1,v2\n")
  assert_eq!(headers.length(), 2)
  assert_eq!(rows.length(), 1)
  assert_eq!(rows[0][0], "v1")
}

test "csv parse to series" {
  let (labels, series_list) = parse_csv_to_series("Label,A,B\nJan,10,20\nFeb,30,40")
  assert_eq!(labels.length(), 2)
  assert_eq!(labels[0], "Jan")
  assert_eq!(labels[1], "Feb")
  assert_eq!(series_list.length(), 2)
  assert_eq!(series_list[0].name, "A")
  assert_eq!(series_list[0].values[0], 10.0)
  assert_eq!(series_list[1].name, "B")
  assert_eq!(series_list[1].values[1], 40.0)
}

test "parse float simple" {
  assert_eq!(parse_float_or_zero("42"), 42.0)
  assert_eq!(parse_float_or_zero("3.14"), 3.14)
  assert_eq!(parse_float_or_zero("-7"), -7.0)
  assert_eq!(parse_float_or_zero("0"), 0.0)
  assert_eq!(parse_float_or_zero("abc"), 0.0)
}

// Demo chart tests

test "demo barchart generates svg" {
  let svg = generate_demo_barchart()
  assert_eq!(svg.contains("<svg"), true)
  assert_eq!(svg.contains("Monthly Revenue"), true)
  assert_eq!(svg.contains("Product A"), true)
  assert_eq!(svg.contains("Product B"), true)
  assert_eq!(svg.contains("</svg>"), true)
}

test "demo linechart generates svg" {
  let svg = generate_demo_linechart()
  assert_eq!(svg.contains("<svg"), true)
  assert_eq!(svg.contains("User Growth"), true)
  assert_eq!(svg.contains("<polyline"), true)
  assert_eq!(svg.contains("</svg>"), true)
}

test "demo piechart generates svg" {
  let svg = generate_demo_piechart()
  assert_eq!(svg.contains("<svg"), true)
  assert_eq!(svg.contains("Market Share"), true)
  assert_eq!(svg.contains("Chrome"), true)
  assert_eq!(svg.contains("<path"), true)
  assert_eq!(svg.contains("</svg>"), true)
}

test "demo scatter generates svg" {
  let svg = generate_demo_scatter()
  assert_eq!(svg.contains("<svg"), true)
  assert_eq!(svg.contains("Height vs Weight"), true)
  assert_eq!(svg.contains("<circle"), true)
  assert_eq!(svg.contains("</svg>"), true)
}

test "demo radar generates svg" {
  let svg = generate_demo_radar()
  assert_eq!(svg.contains("<svg"), true)
  assert_eq!(svg.contains("Player Skill"), true)
  assert_eq!(svg.contains("<polygon"), true)
  assert_eq!(svg.contains("Speed"), true)
  assert_eq!(svg.contains("</svg>"), true)
}

test "demo area generates svg" {
  let svg = generate_demo_area()
  assert_eq!(svg.contains("<svg"), true)
  assert_eq!(svg.contains("Website Traffic"), true)
  assert_eq!(svg.contains("<polygon"), true)
  assert_eq!(svg.contains("</svg>"), true)
}

test "demo dashboard generates svg" {
  let svg = generate_demo_dashboard()
  assert_eq!(svg.contains("<svg"), true)
  assert_eq!(svg.contains("MoonChart Demo Dashboard"), true)
  assert_eq!(svg.contains("</svg>"), true)
}

test "demo all charts render valid svg" {
  let charts = [
    generate_demo_barchart(),
    generate_demo_linechart(),
    generate_demo_piechart(),
    generate_demo_scatter(),
    generate_demo_radar(),
    generate_demo_area(),
    generate_demo_dashboard(),
  ]
  for i = 0; i < charts.length(); i = i + 1 {
    assert_eq!(charts[i].contains("<svg"), true)
    assert_eq!(charts[i].contains("</svg>"), true)
  }
}

test "split lines via parse_csv" {
  let (headers, rows) = parse_csv("a\nb\nc")
  // First line is header: "a"
  assert_eq!(headers.length(), 1)
  assert_eq!(headers[0], "a")
  // Remaining lines are rows
  assert_eq!(rows.length(), 2)
  assert_eq!(rows[0][0], "b")
  assert_eq!(rows[1][0], "c")
}

test "split csv line via parse_csv" {
  let (headers, rows) = parse_csv("a,b,c\n1,2,3")
  assert_eq!(headers.length(), 3)
  assert_eq!(headers[0], "a")
  assert_eq!(headers[1], "b")
  assert_eq!(headers[2], "c")
  assert_eq!(rows.length(), 1)
  assert_eq!(rows[0][0], "1")
}

test "parse float or zero edge cases" {
  assert_eq!(parse_float_or_zero("42"), 42.0)
  assert_eq!(parse_float_or_zero("3.14"), 3.14)
  assert_eq!(parse_float_or_zero("-7"), -7.0)
  assert_eq!(parse_float_or_zero("0"), 0.0)
  assert_eq!(parse_float_or_zero(""), 0.0)
}

test "stackedbar basic render" {
  let chart = StackedBarChart::new()
    .title("Revenue Breakdown")
    .x_labels(["Q1", "Q2"])
    .series(Series::new("Hardware", [100.0, 150.0]))
    .series(Series::new("Software", [80.0, 120.0]))
  let svg = chart.render()
  assert_eq!(svg.contains("<svg"), true)
  assert_eq!(svg.contains("Revenue Breakdown"), true)
  assert_eq!(svg.contains("Hardware"), true)
  assert_eq!(svg.contains("Software"), true)
}

test "stackedbar single series" {
  let chart = StackedBarChart::new()
    .x_labels(["A", "B", "C"])
    .series(Series::new("Only", [10.0, 20.0, 30.0]))
  let svg = chart.render()
  assert_eq!(svg.contains("<svg"), true)
  assert_eq!(svg.contains("<rect"), true)
}

test "stackedbar empty data" {
  let chart = StackedBarChart::new().title("Empty")
  let svg = chart.render()
  assert_eq!(svg.contains("<svg"), true)
  assert_eq!(svg.contains("</svg>"), true)
}

test "stackedbar with custom config" {
  let cfg = ChartConfig::{ colors: ["#FF0000", "#00FF00"], show_grid: false, title_font_size: 20, axis_font_size: 10, legend_font_size: 9 }
  let chart = StackedBarChart::new()
    .title("Test")
    .x_labels(["A", "B"])
    .series(Series::new("S1", [10.0, 20.0]))
    .series(Series::new("S2", [30.0, 15.0]))
    .config(cfg)
  let svg = chart.render()
  assert_eq!(svg.contains("#FF0000"), true)
  assert_eq!(svg.contains("#00FF00"), true)
  assert_eq!(svg.contains("font-size=\"20\""), true)
}

test "horizontal bar basic render" {
  let chart = HorBarChart::new()
    .title("Population")
    .y_labels(["Tokyo", "Delhi", "Shanghai"])
    .series(Series::new("2024", [37.0, 33.0, 29.0]))
  let svg = chart.render()
  assert_eq!(svg.contains("<svg"), true)
  assert_eq!(svg.contains("Tokyo"), true)
  assert_eq!(svg.contains("Population"), true)
  assert_eq!(svg.contains("<rect"), true)
}

test "horizontal bar multi series" {
  let chart = HorBarChart::new()
    .y_labels(["A", "B"])
    .series(Series::new("X", [10.0, 20.0]))
    .series(Series::new("Y", [15.0, 25.0]))
  let svg = chart.render()
  assert_eq!(svg.contains("X"), true)
  assert_eq!(svg.contains("Y"), true)
}

test "donut basic render" {
  let chart = DonutChart::new()
    .title("Browser Share")
    .slice("Chrome", 65.0)
    .slice("Firefox", 8.0)
    .slice("Safari", 18.0)
    .slice("Edge", 9.0)
  let svg = chart.render()
  assert_eq!(svg.contains("<svg"), true)
  assert_eq!(svg.contains("<path"), true)
  assert_eq!(svg.contains("Chrome"), true)
  assert_eq!(svg.contains("65"), true)
}

test "data stats sum" {
  let s = sum([1.0, 2.0, 3.0, 4.0])
  assert_eq!(s, 10.0)
}

test "data stats mean" {
  let m = mean([1.0, 2.0, 3.0, 4.0])
  assert_eq!(m, 2.5)
}

test "data stats min and max" {
  assert_eq!(min_value([3.0, 1.0, 4.0, 2.0]), 1.0)
  assert_eq!(max_value([3.0, 1.0, 4.0, 2.0]), 4.0)
}

test "data stats median" {
  assert_eq!(median([1.0, 3.0, 2.0, 4.0, 5.0]), 3.0)
}

test "theme dark color palette" {
  let t = Theme::dark()
  assert_eq!(t.colors.length(), 10)
  assert_eq!(t.background, "#1a1a2e")
}

test "theme light is default" {
  let t = Theme::light()
  assert_eq!(t.colors[0], "#4E79A7")
}

test "theme to config" {
  let t = Theme::minimal()
  let cfg = t.to_config()
  assert_eq!(cfg.colors.length(), 10)
}

test "barchart with negative values" {
  let chart = BarChart::new()
    .x_labels(["A", "B", "C"])
    .series(Series::new("val", [-10.0, 5.0, -3.0]))
  let svg = chart.render()
  assert_eq!(svg.contains("<svg"), true)
  assert_eq!(svg.contains("<rect"), true)
}

test "linechart with single series no labels" {
  let chart = LineChart::new()
    .series(Series::new("solo", [1.0, 2.0, 3.0, 4.0, 5.0]))
  let svg = chart.render()
  assert_eq!(svg.contains("<polyline"), true)
}

test "scatter with axis labels" {
  let chart = ScatterChart::new()
    .x_label("Height")
    .y_label("Weight")
    .series(ScatterSeries::new("Group A", [(160.0, 55.0), (170.0, 65.0)]))
  let svg = chart.render()
  assert_eq!(svg.contains("Height"), true)
  assert_eq!(svg.contains("Weight"), true)
}

test "radar with grid levels config" {
  let chart = RadarChart::new()
    .axes(["Speed", "Power", "Defense"])
    .series(RadarSeries::new("Player 1", [8.0, 7.0, 9.0]))
  let svg = chart.render()
  assert_eq!(svg.contains("<polygon"), true)
}

test "area chart basic" {
  let chart = AreaChart::new()
    .x_labels(["Q1", "Q2", "Q3"])
    .series(Series::new("revenue", [100.0, 200.0, 150.0]))
  let svg = chart.render()
  assert_eq!(svg.contains("<polygon"), true)
  assert_eq!(svg.contains("<polyline"), true)
}

test "stacked bar multi series stacking" {
  let chart = StackedBarChart::new()
    .x_labels(["A", "B"])
    .series(Series::new("base", [10.0, 20.0]))
    .series(Series::new("top", [5.0, 10.0]))
  let svg = chart.render()
  assert_eq!(svg.contains("<rect"), true)
}

test "horizontal bar with single category" {
  let chart = HorBarChart::new()
    .y_labels(["Tokyo"])
    .series(Series::new("2024", [37.0]))
  let svg = chart.render()
  assert_eq!(svg.contains("<rect"), true)
  assert_eq!(svg.contains("Tokyo"), true)
}

test "donut chart hole ratio" {
  let chart = DonutChart::new()
    .title("Share")
    .slice("A", 60.0)
    .slice("B", 40.0)
  let svg = chart.render()
  assert_eq!(svg.contains("<path"), true)
  assert_eq!(svg.contains("Share"), true)
}

test "csv parse empty input" {
  let (headers, rows) = parse_csv("")
  assert_eq!(headers.length(), 0)
  assert_eq!(rows.length(), 0)
}

test "csv parse single row no data" {
  let (headers, rows) = parse_csv("Name,Value")
  assert_eq!(headers.length(), 2)
  assert_eq!(rows.length(), 0)
}

test "data stats sum" {
  assert_eq!(sum([1.0, 2.0, 3.0]), 6.0)
  assert_eq!(sum([]), 0.0)
}

test "data stats std dev" {
  let s = std_dev([2.0, 4.0, 4.0, 4.0, 5.0, 5.0, 7.0, 9.0])
  assert_eq!(s > 0.0, true)
}

test "barchart builder chain" {
  let c = BarChart::new().title("T").width(600.0).height(300.0)
  let svg = c.render()
  assert_eq!(svg.contains("<svg"), true)
}

test "linechart builder chain" {
  let c = LineChart::new().title("L").width(500.0).height(250.0)
  let svg = c.render()
  assert_eq!(svg.contains("<svg"), true)
}

test "piechart builder chain" {
  let c = PieChart::new().title("P").slice("X", 100.0)
  let svg = c.render()
  assert_eq!(svg.contains("X"), true)
}
