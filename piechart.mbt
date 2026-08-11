///|
struct PieChart {
  title : String
  slices : Array[Slice]
  width : Float
  height : Float
}

///|
pub fn PieChart::new() -> PieChart {
  { title: "", slices: [], width: 500.0, height: 400.0 }
}

///|
pub fn PieChart::title(self : PieChart, t : String) -> PieChart {
  { ..self, title: t }
}

///|
pub fn PieChart::slice(
  self : PieChart,
  name : String,
  value : Float,
) -> PieChart {
  let new_slices = self.slices.copy()
  new_slices.push(Slice::new(name, value))
  { ..self, slices: new_slices }
}

///|
pub fn PieChart::width(self : PieChart, w : Float) -> PieChart {
  { ..self, width: w }
}

///|
pub fn PieChart::height(self : PieChart, h : Float) -> PieChart {
  { ..self, height: h }
}

// Normalize angle to [0, 2π) range

///|
fn normalize_angle(angle : Float) -> Float {
  let tau : Float = 2.0 * 3.1415926535
  let mut a = angle
  while a < 0.0 {
    a = a + tau
  }
  while a >= tau {
    a = a - tau
  }
  a
}

// Taylor series sin approximation with angle reduction to [0, π/2]

///|
fn sin_approx(x : Float) -> Float {
  let pi : Float = 3.1415926535
  let x_norm = normalize_angle(x)
  let sign : Float = if x_norm > pi { -1.0 } else { 1.0 }
  let x_reduced : Float = if x_norm > pi { x_norm - pi } else { x_norm }
  let x_final = if x_reduced > pi / 2.0 { pi - x_reduced } else { x_reduced }
  let x2 = x_final * x_final
  let x3 = x2 * x_final
  let x5 = x3 * x2
  let x7 = x5 * x2
  let f6 : Float = 6.0
  let f120 : Float = 120.0
  let f5040 : Float = 5040.0
  sign * (x_final - x3 / f6 + x5 / f120 - x7 / f5040)
}

// Taylor series cos approximation with angle reduction to [0, π/2]

///|
fn cos_approx(x : Float) -> Float {
  let pi : Float = 3.1415926535
  sin_approx(x + pi / 2.0)
}

///|
fn polar_to_cartesian(
  cx : Float,
  cy : Float,
  r : Float,
  angle_rad : Float,
) -> (Float, Float) {
  let x = cx + r * cos_approx(angle_rad)
  let y = cy + r * sin_approx(angle_rad)
  (x, y)
}

///|
fn slice_path(
  cx : Float,
  cy : Float,
  r : Float,
  start_angle : Float,
  end_angle : Float,
) -> String {
  let pi : Float = 3.1415926535
  let sweep = end_angle - start_angle
  let (start_x, start_y) = polar_to_cartesian(cx, cy, r, start_angle)
  if sweep >= 2.0 * pi - 0.0001 {
    let (mid_x, mid_y) = polar_to_cartesian(cx, cy, r, start_angle + pi)
    "M " +
    cx.to_string() +
    " " +
    cy.to_string() +
    " L " +
    start_x.to_string() +
    " " +
    start_y.to_string() +
    " A " +
    r.to_string() +
    " " +
    r.to_string() +
    " 0 1 0 " +
    mid_x.to_string() +
    " " +
    mid_y.to_string() +
    " A " +
    r.to_string() +
    " " +
    r.to_string() +
    " 0 1 0 " +
    start_x.to_string() +
    " " +
    start_y.to_string() +
    " Z"
  } else {
    let (end_x, end_y) = polar_to_cartesian(cx, cy, r, end_angle)
    let large_arc = if sweep > pi { "1" } else { "0" }
    "M " +
    cx.to_string() +
    " " +
    cy.to_string() +
    " L " +
    end_x.to_string() +
    " " +
    end_y.to_string() +
    " A " +
    r.to_string() +
    " " +
    r.to_string() +
    " 0 " +
    large_arc +
    " 0 " +
    start_x.to_string() +
    " " +
    start_y.to_string() +
    " Z"
  }
}

// Recursive sum of slice values

///|
fn sum_slice_values(slices : Array[Slice], idx : Int, acc : Float) -> Float {
  if idx >= slices.length() {
    acc
  } else {
    let value = if slices[idx].value > 0.0 { slices[idx].value } else { 0.0 }
    sum_slice_values(slices, idx + 1, acc + value)
  }
}

// Format percentage as integer + "%"

///|
fn format_percent(pct : Float) -> String {
  let int_pct = pct.to_int()
  let pct_str = int_pct.to_string()
  pct_str + "%"
}

// Render pie slices recursively

///|
fn render_pie_slices(
  result : String,
  slices : Array[Slice],
  total : Float,
  cx : Float,
  cy : Float,
  r : Float,
  tau : Float,
  idx : Int,
  start_angle : Float,
) -> String {
  if idx >= slices.length() {
    result
  } else if slices[idx].value <= 0.0 {
    render_pie_slices(
      result,
      slices,
      total,
      cx,
      cy,
      r,
      tau,
      idx + 1,
      start_angle,
    )
  } else {
    let fraction = slices[idx].value / total
    let sweep = fraction * tau
    let end_angle = start_angle + sweep
    let color = get_color(idx)

    let with_path = result +
      path(slice_path(cx, cy, r, start_angle, end_angle), color, "#ffffff")

    // Percentage label at mid-angle
    let mid_angle = start_angle + sweep / 2.0
    let label_r = r * 0.68
    let (lx, ly) = polar_to_cartesian(cx, cy, label_r, mid_angle)
    let pct = fraction * 100.0
    let pct_str = format_percent(pct)
    let with_label = with_path + text(lx, ly + 4.0, pct_str, 11, "middle")

    render_pie_slices(
      with_label,
      slices,
      total,
      cx,
      cy,
      r,
      tau,
      idx + 1,
      end_angle,
    )
  }
}

///|
pub fn PieChart::render(self : PieChart) -> String {
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

    if total <= 0.0 {
      return with_title + svg_close()
    }

    // Pie layout: center the pie in the remaining area
    let cx = self.width / 2.0
    let chart_h = self.height - mt - mb - 40.0
    let cy = mt + chart_h / 2.0
    let r = if self.width < self.height {
      self.width / 3.0
    } else {
      chart_h / 2.5
    }

    let tau : Float = 3.1415926535 * 2.0

    // Render slices
    let with_slices = render_pie_slices(
      with_title,
      self.slices,
      total,
      cx,
      cy,
      r,
      tau,
      0,
      0.0,
    )

    // Legend
    let names : Array[String] = []
    for i = 0; i < num_slices; i = i + 1 {
      names.push(self.slices[i].name)
    }
    let with_legend = with_slices +
      render_legend(
        names,
        self.width,
        self.height - 10.0,
        ChartConfig::default(),
      )

    with_legend + svg_close()
  }
}
