///|
fn build_legend_items(
  names : Array[String],
  width : Float,
  item_width : Float,
  columns : Int,
  top_y : Float,
  row_height : Float,
  i : Int,
  acc : String,
  config : ChartConfig,
) -> String {
  if i < names.length() {
    let row = i / columns
    let column = i % columns
    let remaining = names.length() - row * columns
    let items_in_row = if remaining < columns { remaining } else { columns }
    let row_width = item_width * Float::from_int(items_in_row)
    let start_x = (width - row_width) / 2.0
    let x = start_x + Float::from_int(column) * item_width
    let item_y = top_y + Float::from_int(row) * row_height
    let color = get_chart_color(config, i)
    let swatch = rect(x, item_y - 6.0, 12.0, 12.0, color)
    let label = text(
      x + 16.0,
      item_y,
      names[i],
      config.legend_font_size,
      "start",
    )
    build_legend_items(
      names,
      width,
      item_width,
      columns,
      top_y,
      row_height,
      i + 1,
      acc + swatch + label,
      config,
    )
  } else {
    acc
  }
}

///|
pub fn render_legend(
  names : Array[String],
  width : Float,
  y : Float,
  config : ChartConfig,
) -> String {
  if names.length() <= 1 {
    return ""
  }
  let horizontal_padding : Float = 20.0
  let available_width = if width > horizontal_padding {
    width - horizontal_padding
  } else {
    width
  }
  let preferred_item_width : Float = 120.0
  let possible_columns = (available_width / preferred_item_width).to_int()
  let columns = if possible_columns < 1 {
    1
  } else if possible_columns > names.length() {
    names.length()
  } else {
    possible_columns
  }
  let compressed_item_width = available_width / Float::from_int(columns)
  let item_width = if compressed_item_width < preferred_item_width {
    compressed_item_width
  } else {
    preferred_item_width
  }
  let rows = (names.length() + columns - 1) / columns
  let row_height : Float = 18.0
  let top_y = y - Float::from_int(rows - 1) * row_height
  build_legend_items(
    names, width, item_width, columns, top_y, row_height, 0, "", config,
  )
}
