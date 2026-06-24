fn build_legend_items(
  names : Array[String],
  start_x : Float,
  item_width : Float,
  y : Float,
  i : Int,
  acc : String,
  config : ChartConfig,
) -> String {
  if i < names.length() {
    let x = start_x + Float::from_int(i) * item_width
    let color = get_chart_color(config, i)
    let swatch = rect(x, y - 6.0, 12.0, 12.0, color)
    let label = text(x + 16.0, y, names[i], config.legend_font_size, "start")
    build_legend_items(names, start_x, item_width, y, i + 1, acc + swatch + label, config)
  } else {
    acc
  }
}

pub fn render_legend(names : Array[String], width : Float, y : Float, config : ChartConfig) -> String {
  if names.length() <= 1 {
    return ""
  }
  let item_width : Float = 120.0
  let total_w = item_width * Float::from_int(names.length())
  let start_x = (width - total_w) / 2.0
  build_legend_items(names, start_x, item_width, y, 0, "", config)
}
