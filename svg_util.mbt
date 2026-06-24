fn attrs_to_string(attrs : Array[(String, String)]) -> String {
  fn aux(i : Int, acc : String) -> String {
    if i < attrs.length() {
      let (k, v) = attrs[i]
      aux(i + 1, acc + " " + k + "=\"" + v + "\"")
    } else {
      acc
    }
  }
  aux(0, "")
}

fn tag(name : String, attrs : Array[(String, String)], body : String) -> String {
  "<" + name + attrs_to_string(attrs) + ">" + body + "</" + name + ">"
}

fn void_tag(name : String, attrs : Array[(String, String)]) -> String {
  "<" + name + attrs_to_string(attrs) + "/>"
}

pub fn svg_open(width : Float, height : Float) -> String {
  "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"" +
    width.to_string() + "\" height=\"" + height.to_string() + "\">"
}

pub fn svg_close() -> String {
  "</svg>"
}

pub fn rect(x : Float, y : Float, w : Float, h : Float, fill : String) -> String {
  void_tag("rect", [
    ("x", x.to_string()),
    ("y", y.to_string()),
    ("width", w.to_string()),
    ("height", h.to_string()),
    ("fill", fill),
  ])
}

pub fn text(x : Float, y : Float, content : String, font_size : Int, anchor : String) -> String {
  tag("text", [
    ("x", x.to_string()),
    ("y", y.to_string()),
    ("font-size", font_size.to_string()),
    ("font-family", "sans-serif"),
    ("text-anchor", anchor),
  ], content)
}

pub fn line(x1 : Float, y1 : Float, x2 : Float, y2 : Float, stroke : String, stroke_width : Float) -> String {
  void_tag("line", [
    ("x1", x1.to_string()),
    ("y1", y1.to_string()),
    ("x2", x2.to_string()),
    ("y2", y2.to_string()),
    ("stroke", stroke),
    ("stroke-width", stroke_width.to_string()),
  ])
}

pub fn polyline(points : Array[(Float, Float)], stroke : String, stroke_width : Float, fill : String) -> String {
  fn aux(i : Int, acc : String) -> String {
    if i < points.length() {
      let (x, y) = points[i]
      let sep = if i > 0 { " " } else { "" }
      aux(i + 1, acc + sep + x.to_string() + "," + y.to_string())
    } else {
      acc
    }
  }
  let pts = aux(0, "")
  void_tag("polyline", [
    ("points", pts),
    ("stroke", stroke),
    ("stroke-width", stroke_width.to_string()),
    ("fill", fill),
  ])
}

pub fn circle(cx : Float, cy : Float, r : Float, fill : String) -> String {
  void_tag("circle", [
    ("cx", cx.to_string()),
    ("cy", cy.to_string()),
    ("r", r.to_string()),
    ("fill", fill),
  ])
}

pub fn path(d : String, fill : String, stroke : String) -> String {
  void_tag("path", [
    ("d", d),
    ("fill", fill),
    ("stroke", stroke),
    ("stroke-width", "1"),
  ])
}
