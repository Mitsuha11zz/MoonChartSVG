pub(all) struct RadarChart {
  title : String
  axis_labels : Array[String]
  series_list : Array[Series]
  width : Float
  height : Float
  config : ChartConfig
  levels : Int
}

pub fn RadarChart::new() -> RadarChart {
  {
    title: "",
    axis_labels: [],
    series_list: [],
    width: 500.0,
    height: 500.0,
    config: ChartConfig::default(),
    levels: 5,
  }
}

pub fn RadarChart::title(self : RadarChart, t : String) -> RadarChart {
  { ..self, title: t }
}

pub fn RadarChart::axis_labels(self : RadarChart, labels : Array[String]) -> RadarChart {
  { ..self, axis_labels: labels }
}

pub fn RadarChart::series(self : RadarChart, s : Series) -> RadarChart {
  let new_list = self.series_list
  new_list.push(s)
  { ..self, series_list: new_list }
}

pub fn RadarChart::width(self : RadarChart, w : Float) -> RadarChart {
  { ..self, width: w }
}

pub fn RadarChart::height(self : RadarChart, h : Float) -> RadarChart {
  { ..self, height: h }
}

pub fn RadarChart::config(self : RadarChart, c : ChartConfig) -> RadarChart {
  { ..self, config: c }
}

pub fn RadarChart::levels(self : RadarChart, l : Int) -> RadarChart {
  { ..self, levels: l }
}

// Find max value across all series (for scaling data polygons)
fn find_radar_max(series_list : Array[Series], idx : Int, max_val : Float, found : Bool) -> Float {
  if idx >= series_list.length() {
    max_val
  } else {
    let new_max = find_value_max(series_list[idx].values, 0, max_val, found)
    find_radar_max(series_list, idx + 1, new_max, if found { true } else { new_max > 0.0 || max_val > 0.0 })
  }
}

fn find_value_max(values : Array[Float], j : Int, max_val : Float, found : Bool) -> Float {
  if j >= values.length() {
    max_val
  } else {
    let v = values[j]
    let new_max = if found {
      if v > max_val { v } else { max_val }
    } else {
      v
    }
    find_value_max(values, j + 1, new_max, true)
  }
}

// Build polygon points for a given radius (used for concentric grid rings)
fn build_grid_polygon_points(
  result : Array[(Float, Float)],
  cx : Float,
  cy : Float,
  r : Float,
  n : Int,
  angle_step : Float,
  start_angle : Float,
  i : Int,
) -> Array[(Float, Float)] {
  if i >= n {
    result
  } else {
    let angle = start_angle + angle_step * Float::from_int(i)
    let px = cx + r * cos_approx(angle)
    let py = cy + r * sin_approx(angle)
    result.push((px, py))
    build_grid_polygon_points(result, cx, cy, r, n, angle_step, start_angle, i + 1)
  }
}

// Build polygon points for a data series (radius varies per axis)
fn build_series_polygon_points(
  result : Array[(Float, Float)],
  cx : Float,
  cy : Float,
  values : Array[Float],
  max_val : Float,
  chart_r : Float,
  n : Int,
  angle_step : Float,
  start_angle : Float,
  i : Int,
) -> Array[(Float, Float)] {
  if i >= n {
    result
  } else {
    let val = if i < values.length() { values[i] } else { 0.0 }
    let r = if max_val > 0.0 { val / max_val * chart_r } else { 0.0 }
    let angle = start_angle + angle_step * Float::from_int(i)
    let px = cx + r * cos_approx(angle)
    let py = cy + r * sin_approx(angle)
    result.push((px, py))
    build_series_polygon_points(result, cx, cy, values, max_val, chart_r, n, angle_step, start_angle, i + 1)
  }
}

// Render concentric grid polygons
fn render_radar_grid(
  result : String,
  cx : Float,
  cy : Float,
  chart_r : Float,
  n : Int,
  angle_step : Float,
  start_angle : Float,
  levels : Int,
  current_level : Int,
) -> String {
  if current_level > levels {
    result
  } else {
    let r = chart_r * Float::from_int(current_level) / Float::from_int(levels)
    let points : Array[(Float, Float)] = []
    let grid_points = build_grid_polygon_points(points, cx, cy, r, n, angle_step, start_angle, 0)
    let poly = polygon(grid_points, "none", "#cccccc", 1.0)
    render_radar_grid(
      result + poly,
      cx,
      cy,
      chart_r,
      n,
      angle_step,
      start_angle,
      levels,
      current_level + 1,
    )
  }
}

// Render axis lines and labels
fn render_radar_axes(
  result : String,
  cx : Float,
  cy : Float,
  chart_r : Float,
  n : Int,
  angle_step : Float,
  start_angle : Float,
  axis_labels : Array[String],
  i : Int,
  config : ChartConfig,
) -> String {
  if i >= n {
    result
  } else {
    let angle = start_angle + angle_step * Float::from_int(i)
    let ex = cx + chart_r * cos_approx(angle)
    let ey = cy + chart_r * sin_approx(angle)
    let axis_line = line(cx, cy, ex, ey, "#cccccc", 1.0)

    // Place label slightly beyond the end point
    let label_r = chart_r + 18.0
    let lx = cx + label_r * cos_approx(angle)
    let ly = cy + label_r * sin_approx(angle) + 4.0
    let label = text(lx, ly, axis_labels[i], config.axis_font_size, "middle")

    render_radar_axes(
      result + axis_line + label,
      cx,
      cy,
      chart_r,
      n,
      angle_step,
      start_angle,
      axis_labels,
      i + 1,
      config,
    )
  }
}

// Render data series (filled polygons)
fn render_radar_series(
  result : String,
  cx : Float,
  cy : Float,
  chart_r : Float,
  n : Int,
  angle_step : Float,
  start_angle : Float,
  series_list : Array[Series],
  max_val : Float,
  si : Int,
  config : ChartConfig,
) -> String {
  if si >= series_list.length() {
    result
  } else {
    let values = series_list[si].values
    let color = get_chart_color(config, si)
    let points : Array[(Float, Float)] = []
    let series_points = build_series_polygon_points(
      points,
      cx,
      cy,
      values,
      max_val,
      chart_r,
      n,
      angle_step,
      start_angle,
      0,
    )
    let poly = polygon(series_points, color, color, 2.0)
    render_radar_series(
      result + poly,
      cx,
      cy,
      chart_r,
      n,
      angle_step,
      start_angle,
      series_list,
      max_val,
      si + 1,
      config,
    )
  }
}

pub fn RadarChart::render(self : RadarChart) -> String {
  let n = self.axis_labels.length()
  if n == 0 {
    let base = svg_open(self.width, self.height)
    if self.title != "" {
      return base + text(self.width / 2.0, 20.0, self.title, self.config.title_font_size, "middle") + svg_close()
    } else {
      return base + svg_close()
    }
  }

  let pi : Float = 3.1415926535
  let angle_step : Float = 2.0 * pi / Float::from_int(n)
  let start_angle : Float = -pi / 2.0

  // Layout: center the radar chart
  let title_h : Float = 40.0
  let label_margin : Float = 60.0
  let legend_h : Float = 30.0
  let cx = self.width / 2.0
  let cy = title_h + (self.height - title_h - label_margin - legend_h) / 2.0
  let max_r = if (self.width / 2.0 - label_margin) < (cy - title_h * 0.5) {
    self.width / 2.0 - label_margin
  } else {
    cy - title_h * 0.5
  }
  let chart_r = if max_r > 20.0 { max_r } else { 20.0 }

  let base = svg_open(self.width, self.height)

  // Title
  let with_title = if self.title != "" {
    base + text(self.width / 2.0, 20.0, self.title, self.config.title_font_size, "middle")
  } else {
    base
  }

  // Grid rings
  let with_grid = render_radar_grid(
    with_title,
    cx,
    cy,
    chart_r,
    n,
    angle_step,
    start_angle,
    self.levels,
    1,
  )

  // Axes and labels
  let with_axes = render_radar_axes(
    with_grid,
    cx,
    cy,
    chart_r,
    n,
    angle_step,
    start_angle,
    self.axis_labels,
    0,
    self.config,
  )

  // Data series
  let max_val = find_radar_max(self.series_list, 0, 0.0, false)
  let with_series = if self.series_list.length() > 0 && max_val > 0.0 {
    render_radar_series(
      with_axes,
      cx,
      cy,
      chart_r,
      n,
      angle_step,
      start_angle,
      self.series_list,
      max_val,
      0,
      self.config,
    )
  } else {
    with_axes
  }

  // Legend
  let names : Array[String] = []
  for i = 0; i < self.series_list.length(); i = i + 1 {
    names.push(self.series_list[i].name)
  }
  let with_legend = with_series + render_legend(names, self.width, self.height - 10.0, self.config)

  with_legend + svg_close()
}
