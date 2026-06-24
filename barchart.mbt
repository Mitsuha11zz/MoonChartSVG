struct BarChart {
  title : String
  x_labels : Array[String]
  series_list : Array[Series]
  width : Float
  height : Float
}

pub fn BarChart::new() -> BarChart {
  {
    title: "",
    x_labels: [],
    series_list: [],
    width: 800.0,
    height: 400.0,
  }
}

pub fn BarChart::title(self : BarChart, t : String) -> BarChart {
  { ..self, title: t }
}

pub fn BarChart::x_labels(self : BarChart, labels : Array[String]) -> BarChart {
  { ..self, x_labels: labels }
}

pub fn BarChart::series(self : BarChart, s : Series) -> BarChart {
  let new_list = self.series_list
  new_list.push(s)
  { ..self, series_list: new_list }
}

pub fn BarChart::width(self : BarChart, w : Float) -> BarChart {
  { ..self, width: w }
}

pub fn BarChart::height(self : BarChart, h : Float) -> BarChart {
  { ..self, height: h }
}

// Find data range across all series
fn find_data_range(series_list : Array[Series]) -> (Float, Float) {
  fn loop_series(i : Int, min : Float, max : Float, found : Bool) -> (Float, Float) {
    if i < series_list.length() {
      let (new_min, new_max, new_found) =
        find_values_range(series_list[i].values, 0, min, max, found)
      loop_series(i + 1, new_min, new_max, new_found)
    } else {
      (min, max)
    }
  }
  loop_series(0, 0.0, 0.0, false)
}

fn find_values_range(
  values : Array[Float],
  j : Int,
  min : Float,
  max : Float,
  found : Bool,
) -> (Float, Float, Bool) {
  if j < values.length() {
    let v = values[j]
    if found {
      find_values_range(
        values,
        j + 1,
        if v < min { v } else { min },
        if v > max { v } else { max },
        true,
      )
    } else {
      find_values_range(values, j + 1, v, v, true)
    }
  } else {
    (min, max, found)
  }
}

// Render y-axis grid lines and labels recursively
fn render_y_grid(
  acc : String,
  ticks : Array[Float],
  tick_labels : Array[String],
  y_min : Float,
  y_max : Float,
  height : Float,
  mt : Float,
  mb : Float,
  ml : Float,
  mr : Float,
  chart_width : Float,
  i : Int,
) -> String {
  if i < ticks.length() {
    let y_pos = y_to_svg(ticks[i], y_min, y_max, height, mt, mb)
    let grid_line = line(ml - 5.0, y_pos, chart_width - mr, y_pos, "#e0e0e0", 1.0)
    let tick_label = text(ml - 8.0, y_pos + 4.0, tick_labels[i], 11, "end")
    render_y_grid(
      acc + grid_line + tick_label,
      ticks,
      tick_labels,
      y_min,
      y_max,
      height,
      mt,
      mb,
      ml,
      mr,
      chart_width,
      i + 1,
    )
  } else {
    acc
  }
}

// Render bars for a specific category (inner loop over series)
fn render_category_bars(
  acc : String,
  series_list : Array[Series],
  num_series : Int,
  ci : Int,
  bar_w : Float,
  group_x : Float,
  y_min : Float,
  y_max : Float,
  chart_h : Float,
  baseline_y : Float,
  si : Int,
) -> String {
  if si < num_series {
    let val = series_list[si].values[ci]
    let si_float = Float::from_int(si)
    let offset : Float = 0.5
    let bar_x = group_x + bar_w * (si_float + offset)
    let bar_h = (val - y_min) / (y_max - y_min) * chart_h
    let bar_y = baseline_y - bar_h
    let color_str = get_color(si)
    let rect_str = rect(bar_x, bar_y, bar_w, bar_h, color_str)
    render_category_bars(
      acc + rect_str,
      series_list,
      num_series,
      ci,
      bar_w,
      group_x,
      y_min,
      y_max,
      chart_h,
      baseline_y,
      si + 1,
    )
  } else {
    acc
  }
}

// Render bars and x-axis labels (outer loop over categories)
fn render_bars_and_labels(
  acc : String,
  series_list : Array[Series],
  x_labels : Array[String],
  num_categories : Int,
  num_series : Int,
  bar_w : Float,
  group_w : Float,
  y_min : Float,
  y_max : Float,
  height : Float,
  mt : Float,
  mb : Float,
  ml : Float,
  mr : Float,
  chart_width : Float,
  baseline_y : Float,
  ci : Int,
) -> String {
  if ci < num_categories {
    let group_x = x_to_svg(
      Float::from_int(ci),
      Float::from_int(num_categories),
      chart_width,
      ml,
      mr,
    )
    let chart_h = height - mt - mb
    let with_bars = render_category_bars(
      acc,
      series_list,
      num_series,
      ci,
      bar_w,
      group_x,
      y_min,
      y_max,
      chart_h,
      baseline_y,
      0,
    )
    let label_x = group_x + group_w / 2.0
    let with_label = with_bars + text(label_x, baseline_y + 16.0, x_labels[ci], 11, "middle")
    render_bars_and_labels(
      with_label,
      series_list,
      x_labels,
      num_categories,
      num_series,
      bar_w,
      group_w,
      y_min,
      y_max,
      height,
      mt,
      mb,
      ml,
      mr,
      chart_width,
      baseline_y,
      ci + 1,
    )
  } else {
    acc
  }
}

fn min_categories(series_list : Array[Series], max_cat : Int, idx : Int) -> Int {
  if idx >= series_list.length() { max_cat }
  else {
    let next_max = if series_list[idx].values.length() < max_cat {
      series_list[idx].values.length()
    } else { max_cat }
    min_categories(series_list, next_max, idx + 1)
  }
}

pub fn BarChart::render(self : BarChart) -> String {
  let mt : Float = 40.0
  let mb : Float = 60.0
  let ml : Float = 60.0
  let mr : Float = 30.0

  let (d_min, d_max) = find_data_range(self.series_list)
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
  let with_y_grid = render_y_grid(
    with_title,
    axis.ticks,
    axis.tick_labels,
    axis.y_min,
    axis.y_max,
    self.height,
    mt,
    mb,
    ml,
    mr,
    self.width,
    0,
  )

  // X-axis baseline
  let baseline_y = y_to_svg(axis.y_min, axis.y_min, axis.y_max, self.height, mt, mb)
  let with_baseline = with_y_grid + line(ml, baseline_y, self.width - mr, baseline_y, "#888888", 1.0)

  // Bars and x labels
  let num_categories = min_categories(self.series_list, self.x_labels.length(), 0)
  let num_series = self.series_list.length()
  let with_bars = if num_categories > 0 && num_series > 0 {
    let group_w = (self.width - ml - mr) / Float::from_int(num_categories)
    let bar_w = group_w / Float::from_int(num_series + 1)
    render_bars_and_labels(
      with_baseline,
      self.series_list,
      self.x_labels,
      num_categories,
      num_series,
      bar_w,
      group_w,
      axis.y_min,
      axis.y_max,
      self.height,
      mt,
      mb,
      ml,
      mr,
      self.width,
      baseline_y,
      0,
    )
  } else {
    with_baseline
  }

  // Legend
  let names : Array[String] = []
  for i = 0; i < self.series_list.length(); i = i + 1 {
    names.push(self.series_list[i].name)
  }
  let with_legend = with_bars + render_legend(names, self.width, self.height - 10.0)

  with_legend + svg_close()
}
