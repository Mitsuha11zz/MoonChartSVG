struct AxisLayout {
  y_min : Float
  y_max : Float
  step : Float
  ticks : Array[Float]
  tick_labels : Array[String]
}

fn nice_step(range : Float, max_ticks : Int) -> Float {
  let rough_step = range / Float::from_int(max_ticks)
  let rough = rough_step
  if rough >= 1.0 {
    if rough <= 2.0 { 1.0 }
    else if rough <= 5.0 { 2.0 }
    else if rough <= 10.0 { 5.0 }
    else if rough <= 20.0 { 10.0 }
    else if rough <= 50.0 { 20.0 }
    else if rough <= 100.0 { 50.0 }
    else if rough <= 200.0 { 100.0 }
    else if rough <= 500.0 { 200.0 }
    else if rough <= 1000.0 { 500.0 }
    else { 1000.0 }
  } else {
    if rough >= 0.5 { 0.5 }
    else if rough >= 0.2 { 0.2 }
    else if rough >= 0.1 { 0.1 }
    else { 0.05 }
  }
}

fn floor_float(x : Float) -> Float {
  let int_part = x.to_int()
  let as_float = Float::from_int(int_part)
  if as_float > x {
    Float::from_int(int_part - 1)
  } else {
    as_float
  }
}

fn ceil_float(x : Float) -> Float {
  let int_part = x.to_int()
  let as_float = Float::from_int(int_part)
  if as_float < x {
    Float::from_int(int_part + 1)
  } else {
    as_float
  }
}

pub fn compute_y_axis(
  data_min : Float,
  data_max : Float,
  height : Float,
  margin_top : Float,
  margin_bottom : Float,
) -> AxisLayout {
  let max_ticks = 8
  let range = data_max - data_min
  if range == 0.0 {
    let step : Float = 1.0
    let y_min : Float = data_min - step
    let y_max : Float = data_max + step
    AxisLayout::{ y_min, y_max, step, ticks: [], tick_labels: [] }
  } else {
    let step = nice_step(range, max_ticks)
    let y_min = floor_float(data_min / step) * step
    let y_max = (ceil_float(data_max / step) + 1.0) * step
    let ticks = build_ticks(y_min, y_max, step)
    let tick_labels = format_labels(ticks)
    AxisLayout::{ y_min, y_max, step, ticks, tick_labels }
  }
}

fn build_ticks(current : Float, max : Float, step : Float) -> Array[Float] {
  if current > max + step * 0.5 {
    []
  } else {
    let rest = build_ticks(current + step, max, step)
    let result : Array[Float] = [current]
    for i = 0; i < rest.length(); i = i + 1 {
      result.push(rest[i])
    }
    result
  }
}

fn format_labels(ticks : Array[Float]) -> Array[String] {
  let labels : Array[String] = []
  for i = 0; i < ticks.length(); i = i + 1 {
    labels.push(ticks[i].to_string())
  }
  labels
}

pub fn y_to_svg(
  value : Float,
  y_min : Float,
  y_max : Float,
  height : Float,
  margin_top : Float,
  margin_bottom : Float,
) -> Float {
  let chart_h = height - margin_top - margin_bottom
  margin_top + chart_h - (value - y_min) / (y_max - y_min) * chart_h
}

pub fn x_to_svg(index : Float, count : Float, width : Float, margin_left : Float, margin_right : Float) -> Float {
  let chart_w = width - margin_left - margin_right
  margin_left + index / count * chart_w
}
