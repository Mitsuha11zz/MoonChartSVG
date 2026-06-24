pub(all) struct ChartConfig {
  colors : Array[String]     // Custom color palette (empty = use Tableau 10 default)
  show_grid : Bool           // Show Y-axis grid lines (default: true)
  title_font_size : Int      // Title font size (default: 16)
  axis_font_size : Int       // Axis label font size (default: 11)
  legend_font_size : Int     // Legend font size (default: 11)
}

pub fn ChartConfig::default() -> ChartConfig {
  ChartConfig::{ colors: [], show_grid: true, title_font_size: 16, axis_font_size: 11, legend_font_size: 11 }
}

pub fn get_chart_color(config : ChartConfig, index : Int) -> String {
  if config.colors.length() > 0 {
    config.colors[index % config.colors.length()]
  } else {
    get_color(index)
  }
}
