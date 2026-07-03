// HTML wrapper — embed SVG charts in HTML for browser preview

pub fn wrap_html(svg : String) -> String {
  "<!DOCTYPE html>\n<html>\n<head>\n<meta charset=\"utf-8\">\n" +
  "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n" +
  "<title>MoonChartSVG</title>\n<style>\n" +
  "body { margin: 20px; background: #f5f5f5; font-family: sans-serif; }\n" +
  ".chart-container { background: white; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); " +
  "margin-bottom: 20px; padding: 20px; overflow: auto; }\n" +
  "h1 { color: #333; text-align: center; margin-bottom: 30px; }\n" +
  "h2 { color: #555; margin-top: 0; font-size: 16px; }\n" +
  "</style>\n</head>\n<body>\n<h1>MoonChartSVG Chart Gallery</h1>\n" +
  "<div class=\"chart-container\">\n" + svg + "\n</div>\n" +
  "</body>\n</html>"
}

pub fn wrap_html_multi(svgs : Array[String], titles : Array[String]) -> String {
  let result = "<!DOCTYPE html>\n<html>\n<head>\n<meta charset=\"utf-8\">\n" +
  "<title>MoonChartSVG Dashboard</title>\n<style>\n" +
  "body { margin: 20px; background: #f0f0f0; font-family: sans-serif; }\n" +
  "h1 { color: #333; text-align: center; margin-bottom: 30px; }\n" +
  ".dashboard { display: grid; grid-template-columns: repeat(2, 1fr); gap: 20px; }\n" +
  ".chart-card { background: white; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); padding: 16px; }\n" +
  ".chart-card h2 { color: #555; margin: 0 0 12px 0; font-size: 14px; }\n" +
  ".chart-card svg { max-width: 100%%; height: auto; }\n" +
  "</style>\n</head>\n<body>\n<h1>MoonChartSVG Dashboard</h1>\n<div class=\"dashboard\">\n"
  wrap_html_cards(result, svgs, titles, 0) + "</div>\n</body>\n</html>"
}

fn wrap_html_cards(result : String, svgs : Array[String], titles : Array[String], idx : Int) -> String {
  if idx >= svgs.length() { result }
  else {
    let title = if idx < titles.length() { titles[idx] } else { "Chart " + idx.to_string() }
    let card = "<div class=\"chart-card\">\n<h2>" + title + "</h2>\n" + svgs[idx] + "\n</div>\n"
    wrap_html_cards(result + card, svgs, titles, idx + 1)
  }
}

// Inline SVG in HTML with custom styling
pub fn wrap_html_styled(svg : String, bg_color : String, title : String) -> String {
  "<!DOCTYPE html>\n<html>\n<head>\n<meta charset=\"utf-8\">\n" +
  "<title>" + title + "</title>\n<style>\n" +
  "body { margin: 40px; background: " + bg_color + "; display: flex; justify-content: center; }\n" +
  ".chart { background: white; border-radius: 8px; padding: 40px; box-shadow: 0 4px 16px rgba(0,0,0,0.1); }\n" +
  "</style>\n</head>\n<body>\n<div class=\"chart\">\n" + svg + "\n</div>\n</body>\n</html>"
}
