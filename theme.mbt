// Theme presets for quick chart styling

pub(all) struct Theme {
  name : String
  background : String
  text_color : String
  grid_color : String
  axis_color : String
  colors : Array[String]
}

pub fn Theme::dark() -> Theme {
  Theme::{
    name: "dark",
    background: "#1a1a2e",
    text_color: "#e0e0e0",
    grid_color: "#333355",
    axis_color: "#666688",
    colors: ["#00d4ff", "#ff6b6b", "#51cf66", "#ffd43b", "#cc5de8",
             "#20c997", "#ff922b", "#748ffc", "#f06595", "#63e6be"],
  }
}

pub fn Theme::light() -> Theme {
  Theme::{
    name: "light",
    background: "#ffffff",
    text_color: "#333333",
    grid_color: "#e8e8e8",
    axis_color: "#999999",
    colors: ["#4E79A7", "#F28E2B", "#E15759", "#76B7B2", "#59A14F",
             "#EDC948", "#B07AA1", "#FF9DA7", "#9C755F", "#BAB0AC"],
  }
}

pub fn Theme::minimal() -> Theme {
  Theme::{
    name: "minimal",
    background: "#fafafa",
    text_color: "#444444",
    grid_color: "#f0f0f0",
    axis_color: "#cccccc",
    colors: ["#333333", "#666666", "#999999", "#aaaaaa", "#cccccc",
             "#555555", "#777777", "#888888", "#444444", "#bbbbbb"],
  }
}

pub fn Theme::warm() -> Theme {
  Theme::{
    name: "warm",
    background: "#fff8f0",
    text_color: "#5c4033",
    grid_color: "#f0e0d0",
    axis_color: "#c0a080",
    colors: ["#e07b39", "#c44e52", "#8c6b4a", "#55a868", "#ccb974",
             "#d4716b", "#6b8c5c", "#bc8f4f", "#a05252", "#7b9e5a"],
  }
}

pub fn Theme::to_config(self : Theme) -> ChartConfig {
  ChartConfig::{
    colors: self.colors,
    show_grid: true,
    title_font_size: 16,
    axis_font_size: 11,
    legend_font_size: 11,
  }
}
