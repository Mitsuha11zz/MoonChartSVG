pub(all) struct DonutChart {
  title : String
  slices : Array[Slice]
  width : Float
  height : Float
  config : ChartConfig
  hole_ratio : Float
}

pub fn DonutChart::new() -> DonutChart {
  {
    title: "",
    slices: [],
    width: 500.0,
    height: 400.0,
    config: ChartConfig::default(),
    hole_ratio: 0.4,
  }
}

pub fn DonutChart::title(self : DonutChart, t : String) -> DonutChart {
  { ..self, title: t }
}

pub fn DonutChart::slice(self : DonutChart, name : String, value : Float) -> DonutChart {
  let new_slices = self.slices
  new_slices.push(Slice::new(name, value))
  { ..self, slices: new_slices }
}

pub fn DonutChart::width(self : DonutChart, w : Float) -> DonutChart {
  { ..self, width: w }
}

pub fn DonutChart::height(self : DonutChart, h : Float) -> DonutChart {
  { ..self, height: h }
}

pub fn DonutChart::config(self : DonutChart, c : ChartConfig) -> DonutChart {
  { ..self, config: c }
}

pub fn DonutChart::hole_ratio(self : DonutChart, hr : Float) -> DonutChart {
  { ..self, hole_ratio: hr }
}

fn donut_slice_path(
  cx : Float,
  cy : Float,
  outer_r : Float,
  inner_r : Float,
  start_angle : Float,
  end_angle : Float,
) -> String {
  let (outer_start_x, outer_start_y) = polar_to_cartesian(cx, cy, outer_r, start_angle)
  let (outer_end_x, outer_end_y) = polar_to_cartesian(cx, cy, outer_r, end_angle)
  let (inner_start_x, inner_start_y) = polar_to_cartesian(cx, cy, inner_r, start_angle)
  let (inner_end_x, inner_end_y) = polar_to_cartesian(cx, cy, inner_r, end_angle)
  let pi : Float = 3.1415926535
  let large_arc = if end_angle - start_angle > pi { "1" } else { "0" }

  "M " +
  outer_start_x.to_string() + " " + outer_start_y.to_string() +
  " A " + outer_r.to_string() + " " + outer_r.to_string() +
  " 0 " + large_arc + " 0 " +
  outer_end_x.to_string() + " " + outer_end_y.to_string() +
  " L " +
  inner_end_x.to_string() + " " + inner_end_y.to_string() +
  " A " + inner_r.to_string() + " " + inner_r.to_string() +
  " 0 " + large_arc + " 1 " +
  inner_start_x.to_string() + " " + inner_start_y.to_string() +
  " Z"
}

// Render donut slices recursively
fn render_donut_slices(
  result : String,
  slices : Array[Slice],
  total : Float,
  cx : Float,
  cy : Float,
  outer_r : Float,
  inner_r : Float,
  tau : Float,
  idx : Int,
  start_angle : Float,
) -> String {
  if idx >= slices.length() {
    result
  } else {
    let fraction = slices[idx].value / total
    let sweep = fraction * tau
    let end_angle = start_angle + sweep
    let color = get_color(idx)

    let with_path = result +
      path(donut_slice_path(cx, cy, outer_r, inner_r, start_angle, end_angle), color, "#ffffff")

    // Percentage label at mid-angle, positioned halfway between inner and outer radius
    let mid_angle = start_angle + sweep / 2.0
    let label_r = (outer_r + inner_r) / 2.0
    let (lx, ly) = polar_to_cartesian(cx, cy, label_r, mid_angle)
    let pct = fraction * 100.0
    let pct_str = format_percent(pct)
    let with_label = with_path + text(lx, ly + 4.0, pct_str, 11, "middle")

    render_donut_slices(
      with_label,
      slices,
      total,
      cx,
      cy,
      outer_r,
      inner_r,
      tau,
      idx + 1,
      end_angle,
    )
  }
}

pub fn DonutChart::render(self : DonutChart) -> String {
  let mt : Float = 40.0
  let mb : Float = 20.0
  let base = svg_open(self.width, self.height)

  // Title
  let with_title = if self.title != "" {
    base + text(self.width / 2.0, mt - 12.0, self.title, 16, "middle")
  } else {
    base
  }

  let num_slices = self.slices.length()
  if num_slices == 0 {
    with_title + svg_close()
  } else {
    // Calculate total value
    let total = sum_slice_values(self.slices, 0, 0.0)

    // Donut layout: center the donut in the remaining area
    let cx = self.width / 2.0
    let chart_h = self.height - mt - mb - 40.0
    let cy = mt + chart_h / 2.0
    let outer_r = if self.width < self.height { self.width / 3.0 } else { chart_h / 2.5 }
    let inner_r = outer_r * self.hole_ratio

    let tau : Float = 3.1415926535 * 2.0

    // Render slices
    let with_slices = render_donut_slices(
      with_title,
      self.slices,
      total,
      cx,
      cy,
      outer_r,
      inner_r,
      tau,
      0,
      0.0,
    )

    // Center label: show total value
    let center_label = text(cx, cy + 4.0, total.to_string(), 18, "middle")

    // Legend
    let names : Array[String] = []
    for i = 0; i < num_slices; i = i + 1 {
      names.push(self.slices[i].name)
    }
    let with_legend = with_slices + center_label +
      render_legend(names, self.width, self.height - 10.0, self.config)

    with_legend + svg_close()
  }
}
