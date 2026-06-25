pub(all) struct HorBarChart {
  title : String
  y_labels : Array[String]    // Categories (displayed on Y-axis)
  series_list : Array[Series]
  width : Float
  height : Float
  config : ChartConfig
}

pub fn HorBarChart::new() -> HorBarChart {
  {
    title: "",
    y_labels: [],
    series_list: [],
    width: 800.0,
    height: 400.0,
    config: ChartConfig::default(),
  }
}

pub fn HorBarChart::title(self : HorBarChart, t : String) -> HorBarChart {
  { ..self, title: t }
}

pub fn HorBarChart::y_labels(self : HorBarChart, labels : Array[String]) -> HorBarChart {
  { ..self, y_labels: labels }
}

pub fn HorBarChart::series(self : HorBarChart, s : Series) -> HorBarChart {
  let new_list = self.series_list
  new_list.push(s)
  { ..self, series_list: new_list }
}

pub fn HorBarChart::width(self : HorBarChart, w : Float) -> HorBarChart {
  { ..self, width: w }
}

pub fn HorBarChart::height(self : HorBarChart, h : Float) -> HorBarChart {
  { ..self, height: h }
}

pub fn HorBarChart::config(self : HorBarChart, c : ChartConfig) -> HorBarChart {
  { ..self, config: c }
}

// Find max value across all series
fn find_data_max(series_list : Array[Series]) -> Float {
  fn loop_series(i : Int, max_val : Float, found : Bool) -> Float {
    if i < series_list.length() {
      let (new_max, new_found) =
        find_values_max(series_list[i].values, 0, max_val, found)
      loop_series(i + 1, new_max, new_found)
    } else {
      max_val
    }
  }
  loop_series(0, 0.0, false)
}

fn find_values_max(
  values : Array[Float],
  j : Int,
  max_val : Float,
  found : Bool,
) -> (Float, Bool) {
  if j < values.length() {
    let v = values[j]
    if found {
      find_values_max(
        values,
        j + 1,
        if v > max_val { v } else { max_val },
        true,
      )
    } else {
      find_values_max(values, j + 1, v, true)
    }
  } else {
    (max_val, found)
  }
}

// Compute horizontal (X) axis layout: maps data values to SVG x-positions
fn compute_horiz_axis(
  data_max : Float,
  _width : Float,
  _margin_left : Float,
  _margin_right : Float,
) -> AxisLayout {
  let max_ticks = 8
  let zero : Float = Float::from_int(0)
  let one : Float = Float::from_int(1)
  let range = data_max - zero
  if range == zero {
    let step = one
    let x_min = zero - step
    let x_max = data_max + step
    AxisLayout::{ y_min: x_min, y_max: x_max, step, ticks: [], tick_labels: [] }
  } else {
    let step = nice_step(range, max_ticks)
    let x_min = floor_float(zero / step) * step
    let x_max = (ceil_float(data_max / step) + one) * step
    let ticks = build_ticks(x_min, x_max, step)
    let tick_labels = format_labels(ticks)
    AxisLayout::{ y_min: x_min, y_max: x_max, step, ticks, tick_labels }
  }
}

// Render vertical grid lines and X-axis tick labels at the bottom
fn render_vert_grid(
  acc : String,
  ticks : Array[Float],
  tick_labels : Array[String],
  x_min : Float,
  x_max : Float,
  width : Float,
  height : Float,
  mt : Float,
  mb : Float,
  ml : Float,
  mr : Float,
  i : Int,
  config : ChartConfig,
) -> String {
  if i < ticks.length() {
    let chart_w = width - ml - mr
    let x_pos = ml + (ticks[i] - x_min) / (x_max - x_min) * chart_w
    let tick_label = text(
      x_pos,
      height - mb + 16.0,
      tick_labels[i],
      config.axis_font_size,
      "middle",
    )
    let new_acc = if config.show_grid {
      let grid_line = line(x_pos, mt, x_pos, height - mb, "#e0e0e0", 1.0)
      acc + grid_line + tick_label
    } else {
      acc + tick_label
    }
    render_vert_grid(
      new_acc,
      ticks,
      tick_labels,
      x_min,
      x_max,
      width,
      height,
      mt,
      mb,
      ml,
      mr,
      i + 1,
      config,
    )
  } else {
    acc
  }
}

// Render bars for a specific category row (inner loop over series)
fn render_horiz_cat_bars(
  acc : String,
  series_list : Array[Series],
  num_series : Int,
  ci : Int,
  bar_h : Float,
  group_y : Float,
  x_min : Float,
  x_max : Float,
  chart_w : Float,
  ml : Float,
  si : Int,
  config : ChartConfig,
) -> String {
  if si < num_series {
    let val = series_list[si].values[ci]
    let si_float = Float::from_int(si)
    let offset : Float = 0.5
    let bar_y = group_y + bar_h * (si_float + offset)
    let bar_w = (val - x_min) / (x_max - x_min) * chart_w
    let color_str = get_chart_color(config, si)
    let rect_str = rect(ml, bar_y, bar_w, bar_h, color_str)
    render_horiz_cat_bars(
      acc + rect_str,
      series_list,
      num_series,
      ci,
      bar_h,
      group_y,
      x_min,
      x_max,
      chart_w,
      ml,
      si + 1,
      config,
    )
  } else {
    acc
  }
}

// Render bars and Y-axis category labels (outer loop over categories)
fn render_categories(
  acc : String,
  series_list : Array[Series],
  y_labels : Array[String],
  num_categories : Int,
  num_series : Int,
  bar_h : Float,
  group_h : Float,
  x_min : Float,
  x_max : Float,
  width : Float,
  height : Float,
  mt : Float,
  mb : Float,
  ml : Float,
  mr : Float,
  ci : Int,
  config : ChartConfig,
) -> String {
  if ci < num_categories {
    let chart_h = height - mt - mb
    let chart_w = width - ml - mr
    let group_y = mt + Float::from_int(ci) / Float::from_int(num_categories) * chart_h
    let with_bars = render_horiz_cat_bars(
      acc,
      series_list,
      num_series,
      ci,
      bar_h,
      group_y,
      x_min,
      x_max,
      chart_w,
      ml,
      0,
      config,
    )
    let label_y = group_y + group_h / 2.0 + 4.0
    let with_label = with_bars + text(
      ml - 8.0,
      label_y,
      y_labels[ci],
      config.axis_font_size,
      "end",
    )
    render_categories(
      with_label,
      series_list,
      y_labels,
      num_categories,
      num_series,
      bar_h,
      group_h,
      x_min,
      x_max,
      width,
      height,
      mt,
      mb,
      ml,
      mr,
      ci + 1,
      config,
    )
  } else {
    acc
  }
}

pub fn HorBarChart::render(self : HorBarChart) -> String {
  let mt : Float = 40.0
  let mb : Float = 60.0
  let ml : Float = 60.0
  let mr : Float = 30.0

  let data_max_val = find_data_max(self.series_list)
  let axis = compute_horiz_axis(data_max_val, self.width, ml, mr)

  let base = svg_open(self.width, self.height)

  // Title
  let with_title = if self.title != "" {
    base + text(
      self.width / 2.0,
      mt - 12.0,
      self.title,
      self.config.title_font_size,
      "middle",
    )
  } else {
    base
  }

  // Vertical grid lines and X-axis labels at bottom
  let with_v_grid = render_vert_grid(
    with_title,
    axis.ticks,
    axis.tick_labels,
    axis.y_min,
    axis.y_max,
    self.width,
    self.height,
    mt,
    mb,
    ml,
    mr,
    0,
    self.config,
  )

  // Baseline (vertical line at left edge of chart area)
  let with_baseline = with_v_grid + line(
    ml,
    mt,
    ml,
    self.height - mb,
    "#888888",
    1.0,
  )

  // Bars and Y-axis category labels
  let num_categories = min_categories(self.series_list, self.y_labels.length(), 0)
  let num_series = self.series_list.length()
  let with_bars = if num_categories > 0 && num_series > 0 {
    let chart_h = self.height - mt - mb
    let group_h = chart_h / Float::from_int(num_categories)
    let bar_h = group_h / Float::from_int(num_series + 1)
    render_categories(
      with_baseline,
      self.series_list,
      self.y_labels,
      num_categories,
      num_series,
      bar_h,
      group_h,
      axis.y_min,
      axis.y_max,
      self.width,
      self.height,
      mt,
      mb,
      ml,
      mr,
      0,
      self.config,
    )
  } else {
    with_baseline
  }

  // Legend
  let names : Array[String] = []
  for i = 0; i < self.series_list.length(); i = i + 1 {
    names.push(self.series_list[i].name)
  }
  let with_legend = with_bars + render_legend(names, self.width, self.height - 10.0, self.config)

  with_legend + svg_close()
}
