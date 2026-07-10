// Color palettes for chart customization

///|
pub(all) struct Palette {
  name : String
  colors : Array[String]
}

// Tableau 10 (default)

///|
pub fn palette_tableau10() -> Palette {
  Palette::{
    name: "tableau10",
    colors: [
      "#4E79A7", "#F28E2B", "#E15759", "#76B7B2", "#59A14F", "#EDC948", "#B07AA1",
      "#FF9DA7", "#9C755F", "#BAB0AC",
    ],
  }
}

// Pastel palette

///|
pub fn palette_pastel() -> Palette {
  Palette::{
    name: "pastel",
    colors: [
      "#FFB3BA", "#FFDFBA", "#FFFFBA", "#BAFFC9", "#BAE1FF", "#E8BAFF", "#FFB3DE",
      "#B3FFE0", "#FFE0B3", "#B3D4FF",
    ],
  }
}

// Bold palette

///|
pub fn palette_bold() -> Palette {
  Palette::{
    name: "bold",
    colors: [
      "#E6194B", "#3CB44B", "#FFE119", "#4363D8", "#F58231", "#911EB4", "#42D4F4",
      "#F032E6", "#BFEF45", "#FABED4",
    ],
  }
}

// Ocean palette

///|
pub fn palette_ocean() -> Palette {
  Palette::{
    name: "ocean",
    colors: [
      "#003F5C", "#2F4B7C", "#665191", "#A05195", "#D45087", "#F95D6A", "#FF7C43",
      "#FFA600", "#00B4D8", "#90E0EF",
    ],
  }
}

// Forest palette

///|
pub fn palette_forest() -> Palette {
  Palette::{
    name: "forest",
    colors: [
      "#1B4332", "#2D6A4F", "#40916C", "#52B788", "#74C69D", "#95D5B2", "#B7E4C7",
      "#D8F3DC", "#081C15", "#55A630",
    ],
  }
}

// Sunset palette

///|
pub fn palette_sunset() -> Palette {
  Palette::{
    name: "sunset",
    colors: [
      "#FF6B35", "#F7C59F", "#EFEFD0", "#004E89", "#1A659E", "#FF8C42", "#FFB563",
      "#C4513C", "#2A2B2A", "#8BB8A8",
    ],
  }
}

///|
pub fn palette_to_colors(p : Palette) -> Array[String] {
  p.colors
}
