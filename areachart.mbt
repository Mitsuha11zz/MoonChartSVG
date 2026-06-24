pub(all) struct AreaChart {
  title : String
  x_labels : Array[String]
  series_list : Array[Series]
  width : Float
  height : Float
}

pub fn AreaChart::new() -> AreaChart {
  {
    title: "",
    x_labels: [],
    series_list: [],
    width: 800.0,
    height: 400.0,
  }
}

pub fn AreaChart::title(self : AreaChart, t : String) -> AreaChart {
  { ..self, title: t }
}

pub fn AreaChart::x_labels(self : AreaChart, labels : Array[String]) -> AreaChart {
  { ..self, x_labels: labels }
}

pub fn AreaChart::series(self : AreaChart, s : Series) -> AreaChart {
  let new_list = self.series_list
  new_list.push(s)
  { ..self, series_list: new_list }
}

pub fn AreaChart::width(self : AreaChart, w : Float) -> AreaChart {
  { ..self, width: w }
}

pub fn AreaChart::height(self : AreaChart, h : Float) -> AreaChart {
  { ..self, height: h }
}

// Build area polygon points: line points + (last_x, baseline_y) + (first_x, baseline_y)
fn build_area_polygon(pts_list : Array[(Float, Float)], baseline_y : Float) -> Array[(Float, Float)] {
  let area_pts : Array[(Float, Float)] = []
  for i = 0; i < pts_list.length(); i = i + 1 {
    area_pts.push(pts_list[i])
  }
  if pts_list.length() > 0 {
    let (last_x, _) = pts_list[pts_list.length() - 1]
    let (first_x, _) = pts_list[0]
    area_pts.push((last_x, baseline_y))
    area_pts.push((first_x, baseline_y))
  }
  area_pts
}

// Build points array and render area fill + polyline + circles for a single series
fn render_area_points(
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
  baseline_y : Float,
  idx : Int,
  pts_list : Array[(Float, Float)],
) -> String {
  if idx >= num_pts {
    let area_pts = build_area_polygon(pts_list, baseline_y)
    let with_fill = result + polygon(area_pts, color, "none", 0.0)
    let with_line = with_fill + polyline(pts_list, color, 2.0, "none")
    render_line_circles(with_line, pts_list, color, 0)
  } else {
    let px = x_to_svg(Float::from_int(idx), Float::from_int(num_pts), width, ml, mr)
    let py = y_to_svg(values[idx], axis.y_min, axis.y_max, height, mt, mb)
    pts_list.push((px, py))
    render_area_points(
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
      baseline_y,
      idx + 1,
      pts_list,
    )
  }
}

// Render all series (outer loop over series_list)
fn render_area_series(
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
  baseline_y : Float,
  si : Int,
) -> String {
  if si >= series_list.length() {
    result
  } else {
    let values = series_list[si].values
    let color = get_color(si)
    let pts : Array[(Float, Float)] = []
    let with_series = render_area_points(
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
      baseline_y,
      0,
      pts,
    )
    render_area_series(
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
      baseline_y,
      si + 1,
    )
  }
}

pub fn AreaChart::render(self : AreaChart) -> String {
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

  // Area fills and lines
  let num_pts = self.x_labels.length()
  let num_cat = min_line_categories(self.series_list, num_pts, 0)

  let with_areas = if num_cat > 0 && self.series_list.length() > 0 {
    render_area_series(
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
      baseline_y,
      0,
    )
  } else {
    with_baseline
  }

  // X labels
  let with_labels = render_line_x_labels(
    with_areas,
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
