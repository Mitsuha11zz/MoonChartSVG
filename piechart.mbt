struct PieChart {
  title : String
  slices : Array[Slice]
  width : Float
  height : Float
}

pub fn PieChart::new() -> PieChart {
  {
    title: "",
    slices: [],
    width: 500.0,
    height: 400.0,
  }
}

pub fn PieChart::title(self : PieChart, t : String) -> PieChart {
  { ..self, title: t }
}

pub fn PieChart::slice(self : PieChart, name : String, value : Float) -> PieChart {
  let new_slices = self.slices
  new_slices.push(Slice::new(name, value))
  { ..self, slices: new_slices }
}

pub fn PieChart::width(self : PieChart, w : Float) -> PieChart {
  { ..self, width: w }
}

pub fn PieChart::height(self : PieChart, h : Float) -> PieChart {
  { ..self, height: h }
}

// Taylor series sin approximation: x - x^3/3! + x^5/5! - x^7/7!
fn sin_approx(x : Float) -> Float {
  let x2 = x * x
  let x3 = x2 * x
  let x5 = x3 * x2
  let x7 = x5 * x2
  x - x3 / 6.0 + x5 / 120.0 - x7 / 5040.0
}

// Taylor series cos approximation: 1 - x^2/2! + x^4/4! - x^6/6!
fn cos_approx(x : Float) -> Float {
  let x2 = x * x
  let x4 = x2 * x2
  let x6 = x4 * x2
  1.0 - x2 / 2.0 + x4 / 24.0 - x6 / 720.0
}

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

fn slice_path(
  cx : Float,
  cy : Float,
  r : Float,
  start_angle : Float,
  end_angle : Float,
) -> String {
  let (x1, y1) = polar_to_cartesian(cx, cy, r, end_angle)
  let (x2, y2) = polar_to_cartesian(cx, cy, r, start_angle)
  let pi : Float = 3.1415926535
  let large_arc = if end_angle - start_angle > pi { "1" } else { "0" }
  "M " +
  cx.to_string() +
  " " +
  cy.to_string() +
  " L " +
  x1.to_string() +
  " " +
  y1.to_string() +
  " A " +
  r.to_string() +
  " " +
  r.to_string() +
  " 0 " +
  large_arc +
  " 0 " +
  x2.to_string() +
  " " +
  y2.to_string() +
  " Z"
}

// Recursive sum of slice values
fn sum_slice_values(slices : Array[Slice], idx : Int, acc : Float) -> Float {
  if idx >= slices.length() {
    acc
  } else {
    sum_slice_values(slices, idx + 1, acc + slices[idx].value)
  }
}

// Format percentage as integer + "%"
fn format_percent(pct : Float) -> String {
  let int_pct = pct.to_int()
  let pct_str = int_pct.to_string()
  pct_str + "%"
}

// Render pie slices recursively
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

    // Pie layout: center the pie in the remaining area
    let cx = self.width / 2.0
    let chart_h = self.height - mt - mb - 40.0
    let cy = mt + chart_h / 2.0
    let r = if self.width < self.height { self.width / 3.0 } else { chart_h / 2.5 }

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
    let with_legend = with_slices + render_legend(names, self.width, self.height - 10.0, ChartConfig::default())

    with_legend + svg_close()
  }
}
