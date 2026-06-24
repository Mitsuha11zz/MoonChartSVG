// Demo chart generators -- produce complete SVG outputs for all chart types.
// Each function returns a full SVG string that can be saved to a file
// or printed to stdout.

pub fn generate_demo_barchart() -> String {
  BarChart::new()
    .title("Monthly Revenue 2026")
    .x_labels([
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
    ])
    .series(Series::new("Product A", [
      120.0, 200.0, 150.0, 180.0, 220.0, 190.0,
      250.0, 280.0, 300.0, 270.0, 320.0, 350.0,
    ]))
    .series(Series::new("Product B", [
      80.0, 130.0, 170.0, 140.0, 160.0, 200.0,
      180.0, 210.0, 190.0, 230.0, 250.0, 280.0,
    ]))
    .render()
}

pub fn generate_demo_linechart() -> String {
  LineChart::new()
    .title("User Growth 2026")
    .x_labels([
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
    ])
    .series(Series::new("Active Users", [
      1000.0, 1500.0, 2300.0, 3400.0, 4200.0, 5100.0,
      6200.0, 7800.0, 9100.0, 10500.0, 12800.0, 15200.0,
    ]))
    .series(Series::new("New Signups", [
      500.0, 800.0, 1200.0, 900.0, 1100.0, 1400.0,
      1300.0, 1600.0, 1800.0, 1500.0, 2000.0, 2400.0,
    ]))
    .render()
}

pub fn generate_demo_piechart() -> String {
  PieChart::new()
    .title("Market Share by Browser Q2 2026")
    .slice("Chrome", 65.0)
    .slice("Safari", 19.0)
    .slice("Edge", 8.0)
    .slice("Firefox", 3.0)
    .slice("Opera", 3.0)
    .slice("Other", 2.0)
    .render()
}

pub fn generate_demo_scatter() -> String {
  ScatterChart::new()
    .title("Height vs Weight Correlation")
    .x_label("Height (cm)")
    .y_label("Weight (kg)")
    .series(Series::new("Male", [
      175.0, 180.0, 165.0, 190.0, 170.0, 185.0,
      160.0, 178.0, 182.0, 172.0, 188.0, 168.0,
    ]))
    .series(Series::new("Female", [
      160.0, 165.0, 155.0, 170.0, 158.0, 168.0,
      150.0, 163.0, 167.0, 157.0, 172.0, 162.0,
    ]))
    .point_size(5.0)
    .render()
}

pub fn generate_demo_radar() -> String {
  RadarChart::new()
    .title("Player Skill Comparison")
    .axis_labels([
      "Speed", "Power", "Accuracy",
      "Defense", "Stamina", "Teamwork",
    ])
    .series(Series::new("Player A", [
      85.0, 70.0, 90.0, 65.0, 80.0, 75.0,
    ]))
    .series(Series::new("Player B", [
      60.0, 95.0, 55.0, 85.0, 70.0, 80.0,
    ]))
    .series(Series::new("Player C", [
      75.0, 80.0, 70.0, 75.0, 90.0, 65.0,
    ]))
    .width(600.0)
    .height(600.0)
    .render()
}

pub fn generate_demo_area() -> String {
  AreaChart::new()
    .title("Website Traffic Growth 2026")
    .x_labels([
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
    ])
    .series(Series::new("Organic", [
      1200.0, 1500.0, 2100.0, 2800.0, 3400.0, 4200.0,
      5100.0, 6200.0, 7500.0, 8200.0, 9500.0, 11000.0,
    ]))
    .series(Series::new("Paid", [
      600.0, 750.0, 900.0, 1100.0, 1300.0, 1600.0,
      1900.0, 2300.0, 2700.0, 3100.0, 3500.0, 4000.0,
    ]))
    .series(Series::new("Social", [
      300.0, 400.0, 550.0, 700.0, 850.0, 1000.0,
      1200.0, 1500.0, 1800.0, 2100.0, 2400.0, 2800.0,
    ]))
    .render()
}

// Composite demo: a dashboard layout that composes multiple mini charts
// into a single SVG using translate transforms.
pub fn generate_demo_dashboard() -> String {
  let w : Float = 1200.0
  let h : Float = 900.0
  let base = svg_open(w, h)
  let bg = rect(0.0, 0.0, w, h, "#f8f9fa")
  let title = text(w / 2.0, 36.0, "MoonChart Demo Dashboard", 24, "middle")
  let subtitle = text(w / 2.0, 60.0, "All six chart types in one unified view", 14, "middle")

  // Render each mini chart and embed its inner content
  let bar_svg = BarChart::new()
    .title("Q1-Q4 Revenue")
    .x_labels(["Q1", "Q2", "Q3", "Q4"])
    .series(Series::new("A", [120.0, 200.0, 150.0, 280.0]))
    .series(Series::new("B", [80.0, 130.0, 170.0, 210.0]))
    .width(360.0).height(240.0).render()

  let line_svg = LineChart::new()
    .title("Q1-Q4 Growth")
    .x_labels(["Q1", "Q2", "Q3", "Q4"])
    .series(Series::new("Users", [100.0, 250.0, 400.0, 800.0]))
    .width(360.0).height(240.0).render()

  let pie_svg = PieChart::new()
    .title("Browser Share")
    .slice("Chrome", 65.0).slice("Safari", 19.0)
    .slice("Edge", 8.0).slice("Other", 8.0)
    .width(340.0).height(240.0).render()

  let scatter_svg = ScatterChart::new()
    .title("Height vs Weight")
    .x_label("Height").y_label("Weight")
    .series(Series::new("Sample", [
      160.0, 170.0, 175.0, 165.0, 180.0, 172.0,
    ]))
    .width(360.0).height(240.0).render()

  let area_svg = AreaChart::new()
    .title("Traffic Sources")
    .x_labels(["Q1", "Q2", "Q3", "Q4"])
    .series(Series::new("Organic", [500.0, 800.0, 1200.0, 1800.0]))
    .series(Series::new("Paid", [300.0, 450.0, 600.0, 900.0]))
    .width(360.0).height(240.0).render()

  let radar_svg = RadarChart::new()
    .title("Team Skills")
    .axis_labels(["Speed", "Power", "Accuracy", "Defense", "Stamina"])
    .series(Series::new("Team", [80.0, 70.0, 85.0, 75.0, 90.0]))
    .width(340.0).height(280.0).render()

  let inner = bg + title + subtitle +
    embed_chart(bar_svg, 20.0, 80.0) +
    embed_chart(line_svg, 400.0, 80.0) +
    embed_chart(pie_svg, 780.0, 80.0) +
    embed_chart(scatter_svg, 20.0, 350.0) +
    embed_chart(area_svg, 400.0, 350.0) +
    embed_chart(radar_svg, 780.0, 350.0)

  base + inner + svg_close()
}

// Extract the inner content of an SVG string (everything between
// the opening <svg...> tag and the closing </svg> tag) and wrap
// it in a translated <g> group.
fn embed_chart(svg_str : String, dx : Float, dy : Float) -> String {
  let inner = extract_svg_inner(svg_str)
  "<g transform=\"translate(" + dx.to_string() + "," + dy.to_string() + ")\">" + inner + "</g>"
}

// Extract content between the opening <svg...> and closing </svg>.
// Uses String.split() for all string manipulation.
fn extract_svg_inner(svg_str : String) -> String {
  // Step 1: Split on '>' to skip the opening <svg ...> tag.
  // Everything after the first '>' is the inner content (plus closing tag).
  let after_open = skip_first_gt(svg_str)
  // Step 2: Remove the trailing '</svg>' close tag.
  let parts = after_open.split("</svg>").to_array()
  if parts.length() >= 1 {
    parts[0].to_owned()
  } else {
    after_open
  }
}

// Skip everything up to and including the first '>' character.
// Returns the remaining string content.
fn skip_first_gt(s : String) -> String {
  let parts = s.split(">").to_array()
  if parts.length() <= 1 {
    ""
  } else {
    // Rejoin from index 1 onward, with ">" between segments
    join_from(parts, 1, ">")
  }
}

// Join StringView array from index `start` with separator `sep`.
fn join_from(parts : Array[StringView], start : Int, sep : String) -> String {
  if start >= parts.length() {
    ""
  } else {
    let current = parts[start].to_owned()
    let rest = join_from(parts, start + 1, sep)
    if rest == "" {
      current
    } else {
      current + sep + rest
    }
  }
}
