struct LineChart {
  title : String
  x_labels : Array[String]
  series_list : Array[Series]
  width : Float
  height : Float
}

pub fn LineChart::new() -> LineChart {
  {
    title: "",
    x_labels: [],
    series_list: [],
    width: 800.0,
    height: 400.0,
  }
}

pub fn LineChart::title(self : LineChart, t : String) -> LineChart {
  { ..self, title: t }
}

pub fn LineChart::x_labels(self : LineChart, labels : Array[String]) -> LineChart {
  { ..self, x_labels: labels }
}

pub fn LineChart::series(self : LineChart, s : Series) -> LineChart {
  let new_list = self.series_list
  new_list.push(s)
  { ..self, series_list: new_list }
}

pub fn LineChart::width(self : LineChart, w : Float) -> LineChart {
  { ..self, width: w }
}

pub fn LineChart::height(self : LineChart, h : Float) -> LineChart {
  { ..self, height: h }
}

// Find data range across all series using nested recursion (same pattern as barchart)
fn find_line_data_range(series_list : Array[Series]) -> (Float, Float) {
  fn loop_series(i : Int, min : Float, max : Float, found : Bool) -> (Float, Float) {
    if i < series_list.length() {
      let (new_min, new_max, new_found) =
        find_line_values_range(series_list[i].values, 0, min, max, found)
      loop_series(i + 1, new_min, new_max, new_found)
    } else {
      (min, max)
    }
  }
  loop_series(0, 0.0, 0.0, false)
}

fn find_line_values_range(
  values : Array[Float],
  j : Int,
  min : Float,
  max : Float,
  found : Bool,
) -> (Float, Float, Bool) {
  if j < values.length() {
    let v = values[j]
    if found {
      find_line_values_range(
        values,
        j + 1,
        if v < min { v } else { min },
        if v > max { v } else { max },
        true,
      )
    } else {
      find_line_values_range(values, j + 1, v, v, true)
    }
  } else {
    (min, max, found)
  }
}

// Bounds check: minimum categories across all series to avoid index out of bounds
fn min_line_categories(series_list : Array[Series], cur_min : Int, idx : Int) -> Int {
  if idx >= series_list.length() {
    cur_min
  } else {
    let len = series_list[idx].values.length()
    let new_min = if len < cur_min { len } else { cur_min }
    min_line_categories(series_list, new_min, idx + 1)
  }
}

// Render y-axis grid lines and labels recursively
fn render_line_y_grid(
  result : String,
  axis : AxisLayout,
  height : Float,
  mt : Float,
  mb : Float,
  width : Float,
  ml : Float,
  mr : Float,
  idx : Int,
) -> String {
  if idx < axis.ticks.length() {
    let y_pos = y_to_svg(axis.ticks[idx], axis.y_min, axis.y_max, height, mt, mb)
    let grid_line = line(ml - 5.0, y_pos, width - mr, y_pos, "#e0e0e0", 1.0)
    let label = text(ml - 8.0, y_pos + 4.0, axis.tick_labels[idx], 11, "end")
    render_line_y_grid(
      result + grid_line + label,
      axis,
      height,
      mt,
      mb,
      width,
      ml,
      mr,
      idx + 1,
    )
  } else {
    result
  }
}

// Render circles for each data point in a series
fn render_line_circles(
  result : String,
  pts : Array[(Float, Float)],
  color : String,
  idx : Int,
) -> String {
  if idx >= pts.length() {
    result
  } else {
    let (cx, cy) = pts[idx]
    let c = circle(cx, cy, 4.0, color)
    render_line_circles(result + c, pts, color, idx + 1)
  }
}

// Build points array and render polyline + circles for a single series
fn render_line_points(
  result : String,
  values : Array[Float],
  num_pts : Int,
  axis : AxisLayout,
  height : Float,
  mt : Float,
  mb : Float,
  width : Float,
  ml : Float,
  mr : Float,
  color : String,
  idx : Int,
  pts_list : Array[(Float, Float)],
) -> String {
  if idx >= num_pts {
    let with_poly = result + polyline(pts_list, color, 2.0, "none")
    render_line_circles(with_poly, pts_list, color, 0)
  } else {
    let px = x_to_svg(Float::from_int(idx), Float::from_int(num_pts), width, ml, mr)
    let py = y_to_svg(values[idx], axis.y_min, axis.y_max, height, mt, mb)
    pts_list.push((px, py))
    render_line_points(
      result,
      values,
      num_pts,
      axis,
      height,
      mt,
      mb,
      width,
      ml,
      mr,
      color,
      idx + 1,
      pts_list,
    )
  }
}

// Render all series (outer loop over series_list)
fn render_line_series(
  result : String,
  series_list : Array[Series],
  num_cat : Int,
  axis : AxisLayout,
  height : Float,
  mt : Float,
  mb : Float,
  width : Float,
  ml : Float,
  mr : Float,
  si : Int,
) -> String {
  if si >= series_list.length() {
    result
  } else {
    let values = series_list[si].values
    let color = get_color(si)
    let pts : Array[(Float, Float)] = []
    let with_series = render_line_points(
      result,
      values,
      num_cat,
      axis,
      height,
      mt,
      mb,
      width,
      ml,
      mr,
      color,
      0,
      pts,
    )
    render_line_series(
      with_series,
      series_list,
      num_cat,
      axis,
      height,
      mt,
      mb,
      width,
      ml,
      mr,
      si + 1,
    )
  }
}

// Render x-axis category labels recursively
fn render_line_x_labels(
  result : String,
  x_labels : Array[String],
  num_cat : Int,
  width : Float,
  ml : Float,
  mr : Float,
  baseline_y : Float,
  idx : Int,
) -> String {
  if idx >= num_cat {
    result
  } else {
    let px = x_to_svg(Float::from_int(idx), Float::from_int(num_cat), width, ml, mr)
    let label = text(px, baseline_y + 16.0, x_labels[idx], 11, "middle")
    render_line_x_labels(
      result + label,
      x_labels,
      num_cat,
      width,
      ml,
      mr,
      baseline_y,
      idx + 1,
    )
  }
}

pub fn LineChart::render(self : LineChart) -> String {
  let mt : Float = 40.0
  let mb : Float = 60.0
  let ml : Float = 60.0
  let mr : Float = 30.0

  let (d_min, d_max) = find_line_data_range(self.series_list)
  let data_min = if d_min > 0.0 { Float::from_int(0) } else { d_min }
  let axis = compute_y_axis(data_min, d_max, self.height, mt, mb)

  let base = svg_open(self.width, self.height)

  // Title
  let with_title = if self.title != "" {
    base + text(self.width / 2.0, mt - 12.0, self.title, 16, "middle")
  } else {
    base
  }

  // Y-axis grid lines and labels
  let with_y_grid = render_line_y_grid(
    with_title,
    axis,
    self.height,
    mt,
    mb,
    self.width,
    ml,
    mr,
    0,
  )

  // X-axis baseline
  let baseline_y = y_to_svg(axis.y_min, axis.y_min, axis.y_max, self.height, mt, mb)
  let with_baseline = with_y_grid + line(ml, baseline_y, self.width - mr, baseline_y, "#888888", 1.0)

  // Lines and circles — compute safe number of categories
  let num_pts = self.x_labels.length()
  let num_cat = min_line_categories(self.series_list, num_pts, 0)

  let with_lines = if num_cat > 0 && self.series_list.length() > 0 {
    render_line_series(
      with_baseline,
      self.series_list,
      num_cat,
      axis,
      self.height,
      mt,
      mb,
      self.width,
      ml,
      mr,
      0,
    )
  } else {
    with_baseline
  }

  // X labels
  let with_labels = render_line_x_labels(
    with_lines,
    self.x_labels,
    num_cat,
    self.width,
    ml,
    mr,
    baseline_y,
    0,
  )

  // Legend
  let names : Array[String] = []
  for i = 0; i < self.series_list.length(); i = i + 1 {
    names.push(self.series_list[i].name)
  }
  let with_legend = with_labels + render_legend(names, self.width, self.height - 10.0)

  with_legend + svg_close()
}
