let tableau10 : Array[String] = [
  "#4E79A7", "#F28E2B", "#E15759", "#76B7B2", "#59A14F",
  "#EDC948", "#B07AA1", "#FF9DA7", "#9C755F", "#BAB0AC",
]

pub fn get_color(index : Int) -> String {
  tableau10[index % tableau10.length()]
}
