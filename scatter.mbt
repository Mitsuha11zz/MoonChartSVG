pub(all) struct ScatterChart {
  title : String
  x_label : String
  y_label : String
  series_list : Array[Series]
  width : Float
  height : Float
  config : ChartConfig
  point_size : Float
}

pub fn ScatterChart::new() -> ScatterChart {
  {
    title: "",
    x_label: "",
    y_label: "",
    series_list: [],
    width: 800.0,
    height: 400.0,
    config: ChartConfig::default(),
    point_size: 4.0,
  }
}

pub fn ScatterChart::title(self : ScatterChart, t : String) -> ScatterChart {
  { ..self, title: t }
}

pub fn ScatterChart::x_label(self : ScatterChart, label : String) -> ScatterChart {
  { ..self, x_label: label }
}

pub fn ScatterChart::y_label(self : ScatterChart, label : String) -> ScatterChart {
  { ..self, y_label: label }
}

pub fn ScatterChart::series(self : ScatterChart, s : Series) -> ScatterChart {
  let new_list = self.series_list
  new_list.push(s)
  { ..self, series_list: new_list }
}

pub fn ScatterChart::width(self : ScatterChart, w : Float) -> ScatterChart {
  { ..self, width: w }
}

pub fn ScatterChart::height(self : ScatterChart, h : Float) -> ScatterChart {
  { ..self, height: h }
}

pub fn ScatterChart::config(self : ScatterChart, c : ChartConfig) -> ScatterChart {
  { ..self, config: c }
}

pub fn ScatterChart::point_size(self : ScatterChart, ps : Float) -> ScatterChart {
  { ..self, point_size: ps }
}

// Find data range across all series
fn find_scatter_data_range(series_list : Array[Series]) -> (Float, Float) {
  fn loop_series(i : Int, min : Float, max : Float, found : Bool) -> (Float, Float) {
    if i < series_list.length() {
      let (new_min, new_max, new_found) =
        find_scatter_values_range(series_list[i].values, 0, min, max, found)
      loop_series(i + 1, new_min, new_max, new_found)
    } else {
      (min, max)
    }
  }
  loop_series(0, 0.0, 0.0, false)
}

fn find_scatter_values_range(
  values : Array[Float],
  j : Int,
  min : Float,
  max : Float,
  found : Bool,
) -> (Float, Float, Bool) {
  if j < values.length() {
    let v = values[j]
    if found {
      find_scatter_values_range(
        values,
        j + 1,
        if v < min { v } else { min },
        if v > max { v } else { max },
        true,
      )
    } else {
      find_scatter_values_range(values, j + 1, v, v, true)
    }
  } else {
    (min, max, found)
  }
}

// Render y-axis grid lines and labels recursively
fn render_scatter_y_grid(
  result : String,
  axis : AxisLayout,
  height : Float,
  mt : Float,
  mb : Float,
  width : Float,
  ml : Float,
  mr : Float,
  idx : Int,
  config : ChartConfig,
) -> String {
  if idx < axis.ticks.length() {
    let y_pos = y_to_svg(axis.ticks[idx], axis.y_min, axis.y_max, height, mt, mb)
    let label = text(ml - 8.0, y_pos + 4.0, axis.tick_labels[idx], config.axis_font_size, "end")
    let new_result = if config.show_grid {
      let grid_line = line(ml - 5.0, y_pos, width - mr, y_pos, "#e0e0e0", 1.0)
      result + grid_line + label
    } else {
      result + label
    }
    render_scatter_y_grid(
      new_result,
      axis,
      height,
      mt,
      mb,
      width,
      ml,
      mr,
      idx + 1,
      config,
    )
  } else {
    result
  }
}

// Bounds check: minimum categories across all series to avoid index out of bounds
fn min_scatter_categories(series_list : Array[Series], cur_min : Int, idx : Int) -> Int {
  if idx >= series_list.length() {
    cur_min
  } else {
    let len = series_list[idx].values.length()
    let new_min = if len < cur_min { len } else { cur_min }
    min_scatter_categories(series_list, new_min, idx + 1)
  }
}

// Find max categories across all series (used for X axis extent)
fn max_scatter_categories(series_list : Array[Series], cur_max : Int, idx : Int) -> Int {
  if idx >= series_list.length() {
    cur_max
  } else {
    let len = series_list[idx].values.length()
    let new_max = if len > cur_max { len } else { cur_max }
    max_scatter_categories(series_list, new_max, idx + 1)
  }
}

// Render circles for a single series
fn render_scatter_circles(
  result : String,
  values : Array[Float],
  num_cat : Int,
  axis : AxisLayout,
  height : Float,
  mt : Float,
  mb : Float,
  width : Float,
  ml : Float,
  mr : Float,
  color : String,
  radius : Float,
  idx : Int,
) -> String {
  if idx >= num_cat {
    result
  } else {
    let cx = x_to_svg(Float::from_int(idx), Float::from_int(num_cat), width, ml, mr)
    let cy = y_to_svg(values[idx], axis.y_min, axis.y_max, height, mt, mb)
    let c = circle(cx, cy, radius, color)
    render_scatter_circles(
      result + c,
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
      radius,
      idx + 1,
    )
  }
}

// Render all series (outer loop over series_list)
fn render_scatter_series(
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
  point_size : Float,
  si : Int,
  config : ChartConfig,
) -> String {
  if si >= series_list.length() {
    result
  } else {
    let values = series_list[si].values
    let color = get_chart_color(config, si)
    let with_circles = render_scatter_circles(
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
      point_size,
      0,
    )
    render_scatter_series(
      with_circles,
      series_list,
      num_cat,
      axis,
      height,
      mt,
      mb,
      width,
      ml,
      mr,
      point_size,
      si + 1,
      config,
    )
  }
}

pub fn ScatterChart::render(self : ScatterChart) -> String {
  let mt : Float = 40.0
  let mb : Float = 60.0
  let ml : Float = 60.0
  let mr : Float = 30.0

  let (d_min, d_max) = find_scatter_data_range(self.series_list)
  let data_min = if d_min > 0.0 { Float::from_int(0) } else { d_min }
  let axis = compute_y_axis(data_min, d_max, self.height, mt, mb)

  let base = svg_open(self.width, self.height)

  // Title
  let with_title = if self.title != "" {
    base + text(self.width / 2.0, mt - 12.0, self.title, self.config.title_font_size, "middle")
  } else {
    base
  }

  // Y-axis grid lines and labels
  let with_y_grid = render_scatter_y_grid(
    with_title,
    axis,
    self.height,
    mt,
    mb,
    self.width,
    ml,
    mr,
    0,
    self.config,
  )

  // X-axis baseline
  let baseline_y = y_to_svg(axis.y_min, axis.y_min, axis.y_max, self.height, mt, mb)
  let with_baseline = with_y_grid + line(ml, baseline_y, self.width - mr, baseline_y, "#888888", 1.0)

  // Y-axis label
  let with_y_axis_label = if self.y_label != "" {
    with_baseline + text(14.0, mt + (self.height - mt - mb) / 2.0, self.y_label, self.config.axis_font_size, "middle")
  } else {
    with_baseline
  }

  // X-axis label
  let with_x_axis_label = if self.x_label != "" {
    with_y_axis_label + text(self.width / 2.0, baseline_y + 36.0, self.x_label, self.config.axis_font_size, "middle")
  } else {
    with_y_axis_label
  }

  // Scatter circles
  let num_max = max_scatter_categories(self.series_list, 0, 0)
  let num_cat = min_scatter_categories(self.series_list, num_max, 0)

  let with_circles = if num_cat > 0 && self.series_list.length() > 0 {
    render_scatter_series(
      with_x_axis_label,
      self.series_list,
      num_cat,
      axis,
      self.height,
      mt,
      mb,
      self.width,
      ml,
      mr,
      self.point_size,
      0,
      self.config,
    )
  } else {
    with_x_axis_label
  }

  // Legend
  let names : Array[String] = []
  for i = 0; i < self.series_list.length(); i = i + 1 {
    names.push(self.series_list[i].name)
  }
  let with_legend = with_circles + render_legend(names, self.width, self.height - 10.0, self.config)

  with_legend + svg_close()
}
