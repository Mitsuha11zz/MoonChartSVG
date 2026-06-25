pub(all) struct StackedBarChart {
  title : String
  x_labels : Array[String]
  series_list : Array[Series]
  width : Float
  height : Float
  config : ChartConfig
}

pub fn StackedBarChart::new() -> StackedBarChart {
  {
    title: "",
    x_labels: [],
    series_list: [],
    width: 800.0,
    height: 400.0,
    config: ChartConfig::default(),
  }
}

pub fn StackedBarChart::title(self : StackedBarChart, t : String) -> StackedBarChart {
  { ..self, title: t }
}

pub fn StackedBarChart::x_labels(self : StackedBarChart, labels : Array[String]) -> StackedBarChart {
  { ..self, x_labels: labels }
}

pub fn StackedBarChart::series(self : StackedBarChart, s : Series) -> StackedBarChart {
  let new_list = self.series_list
  new_list.push(s)
  { ..self, series_list: new_list }
}

pub fn StackedBarChart::width(self : StackedBarChart, w : Float) -> StackedBarChart {
  { ..self, width: w }
}

pub fn StackedBarChart::height(self : StackedBarChart, h : Float) -> StackedBarChart {
  { ..self, height: h }
}

pub fn StackedBarChart::config(self : StackedBarChart, c : ChartConfig) -> StackedBarChart {
  { ..self, config: c }
}

// Compute the sum of values across all series for a single category
fn compute_category_sum(
  series_list : Array[Series],
  ci : Int,
  si : Int,
  acc : Float,
) -> Float {
  if si < series_list.length() {
    compute_category_sum(series_list, ci, si + 1, acc + series_list[si].values[ci])
  } else {
    acc
  }
}

// Find the maximum total (stacked) value across all categories
fn find_max_category_sum(series_list : Array[Series], num_categories : Int) -> Float {
  fn loop_category(ci : Int, max_sum : Float) -> Float {
    if ci < num_categories {
      let sum = compute_category_sum(series_list, ci, 0, 0.0)
      let new_max = if sum > max_sum { sum } else { max_sum }
      loop_category(ci + 1, new_max)
    } else {
      max_sum
    }
  }
  loop_category(0, 0.0)
}

// Render stacked rectangles for a single category (recursive over series)
fn render_category_stacked(
  acc : String,
  series_list : Array[Series],
  num_series : Int,
  ci : Int,
  bar_x : Float,
  bar_w : Float,
  y_min : Float,
  y_max : Float,
  chart_h : Float,
  si : Int,
  cumulative_y : Float,
  config : ChartConfig,
) -> String {
  if si < num_series {
    let val = series_list[si].values[ci]
    let bar_h = (val - y_min) / (y_max - y_min) * chart_h
    let bar_y = cumulative_y - bar_h
    let color_str = get_chart_color(config, si)
    let rect_str = rect(bar_x, bar_y, bar_w, bar_h, color_str)
    render_category_stacked(
      acc + rect_str,
      series_list,
      num_series,
      ci,
      bar_x,
      bar_w,
      y_min,
      y_max,
      chart_h,
      si + 1,
      cumulative_y - bar_h,
      config,
    )
  } else {
    acc
  }
}

// Render stacked bars and x-axis labels (recursive over categories)
fn render_stacked_bars_and_labels(
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
  config : ChartConfig,
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
    let bar_x = group_x + (group_w - bar_w) / 2.0
    let with_bars = render_category_stacked(
      acc,
      series_list,
      num_series,
      ci,
      bar_x,
      bar_w,
      y_min,
      y_max,
      chart_h,
      0,
      baseline_y,
      config,
    )
    let label_x = group_x + group_w / 2.0
    let with_label = with_bars +
      text(label_x, baseline_y + 16.0, x_labels[ci], config.axis_font_size, "middle")
    render_stacked_bars_and_labels(
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
      config,
    )
  } else {
    acc
  }
}

pub fn StackedBarChart::render(self : StackedBarChart) -> String {
  let mt : Float = 40.0
  let mb : Float = 60.0
  let ml : Float = 60.0
  let mr : Float = 30.0

  let num_categories = min_categories(self.series_list, self.x_labels.length(), 0)
  let num_series = self.series_list.length()

  // Compute y-axis range: from 0 to max total sum across all categories
  let max_sum = if num_categories > 0 && num_series > 0 {
    find_max_category_sum(self.series_list, num_categories)
  } else {
    0.0
  }
  let data_max = if max_sum > 0.0 { max_sum } else { 1.0 }
  let axis = compute_y_axis(0.0, data_max, self.height, mt, mb)

  let base = svg_open(self.width, self.height)

  // Title
  let with_title = if self.title != "" {
    base +
      text(self.width / 2.0, mt - 12.0, self.title, self.config.title_font_size, "middle")
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
    self.config,
  )

  // X-axis baseline
  let baseline_y = y_to_svg(axis.y_min, axis.y_min, axis.y_max, self.height, mt, mb)
  let with_baseline = with_y_grid +
    line(ml, baseline_y, self.width - mr, baseline_y, "#888888", 1.0)

  // Stacked bars and x labels
  let group_w = if num_categories > 0 {
    (self.width - ml - mr) / Float::from_int(num_categories)
  } else {
    0.0
  }
  let bar_w = group_w * 0.6
  let with_bars = if num_categories > 0 && num_series > 0 {
    render_stacked_bars_and_labels(
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
  let with_legend = with_bars +
    render_legend(names, self.width, self.height - 10.0, self.config)

  with_legend + svg_close()
}
