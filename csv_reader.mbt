// CSV Reader -- Parse comma-separated data with headers
//
// Supports newline-delimited rows with comma-separated fields.
// First row is treated as headers; remaining rows are data.
// Uses MoonBit's built-in String.split() for simplicity.

// Parse CSV text into (headers, rows)
pub fn parse_csv(content : String) -> (Array[String], Array[Array[String]]) {
  let line_views = content.split("\n").to_array()
  // Collect non-empty lines
  let lines : Array[String] = []
  for i = 0; i < line_views.length(); i = i + 1 {
    let line = line_views[i].to_owned()
    if line != "" {
      lines.push(line)
    }
  }
  if lines.length() == 0 {
    ([], [])
  } else {
    // First line = headers
    let hdr_views = lines[0].split(",").to_array()
    let headers : Array[String] = []
    for i = 0; i < hdr_views.length(); i = i + 1 {
      headers.push(hdr_views[i].to_owned())
    }
    // Remaining lines = data rows
    let rows : Array[Array[String]] = []
    for i = 1; i < lines.length(); i = i + 1 {
      let fld_views = lines[i].split(",").to_array()
      let fields : Array[String] = []
      for j = 0; j < fld_views.length(); j = j + 1 {
        fields.push(fld_views[j].to_owned())
      }
      rows.push(fields)
    }
    (headers, rows)
  }
}

// Parse CSV with numeric values, returning labels and Series objects.
// Headers: "Label,Series1Name,Series2Name,..."
// First column = category labels, remaining columns = data series.
pub fn parse_csv_to_series(content : String) -> (Array[String], Array[Series]) {
  let (headers, rows) = parse_csv(content)
  let num_series = if headers.length() > 1 { headers.length() - 1 } else { 0 }
  if num_series == 0 || rows.length() == 0 {
    ([], [])
  } else {
    let series_list : Array[Series] = []
    for si = 0; si < num_series; si = si + 1 {
      let values : Array[Float] = []
      for ri = 0; ri < rows.length(); ri = ri + 1 {
        let row = rows[ri]
        let col_idx = si + 1
        if col_idx < row.length() {
          values.push(parse_float_or_zero(row[col_idx]))
        } else {
          values.push(0.0)
        }
      }
      series_list.push(Series::new(headers[si + 1], values))
    }
    let labels : Array[String] = []
    for ri = 0; ri < rows.length(); ri = ri + 1 {
      labels.push(rows[ri][0])
    }
    (labels, series_list)
  }
}

// Parse a string to Float. Handles integers, decimals (e.g. "3.14"),
// and negative numbers (e.g. "-7"). Returns 0.0 on failure.
pub fn parse_float_or_zero(s : String) -> Float {
  let len = s.length()
  if len == 0 {
    Float::from_int(0)
  } else {
    parse_float_impl(s, 0, len)
  }
}

fn parse_float_impl(s : String, i : Int, len : Int) -> Float {
  // Check for negative sign
  let pair : (Float, Int) = if i < len && s[i] == 45 {
    (Float::from_int(-1), i + 1)
  } else {
    (Float::from_int(1), i)
  }
  let sign = pair.0
  let start = pair.1
  let (int_val, after_int) = parse_int_digits(s, start, len, Float::from_int(0))
  if after_int < len && s[after_int] == 46 {
    let place_val : Float = Float::from_int(1) / Float::from_int(10)
    let (frac_val, _) = parse_frac_digits(s, after_int + 1, len, Float::from_int(0), place_val)
    sign * (int_val + frac_val)
  } else {
    sign * int_val
  }
}

// Parse a sequence of digit characters into a Float value.
// Returns (accumulated value, next index).
fn parse_int_digits(s : String, i : Int, len : Int, acc : Float) -> (Float, Int) {
  if i >= len {
    (acc, i)
  } else {
    let ch = s[i]  // UInt16 character code
    if ch >= 48 && ch <= 57 {
      let digit = code_to_float(ch)
      parse_int_digits(s, i + 1, len, acc * Float::from_int(10) + digit)
    } else {
      (acc, i)
    }
  }
}

// Parse fractional digits after decimal point.
// Returns (accumulated fraction, next index).
fn parse_frac_digits(s : String, i : Int, len : Int, acc : Float, place : Float) -> (Float, Int) {
  if i >= len {
    (acc, i)
  } else {
    let ch = s[i]
    if ch >= 48 && ch <= 57 {
      let digit = code_to_float(ch)
      let new_place : Float = place / Float::from_int(10)
      parse_frac_digits(s, i + 1, len, acc + digit * place, new_place)
    } else {
      (acc, i)
    }
  }
}

// Convert UInt16 character code for '0'-'9' to Float value.
fn code_to_float(code : UInt16) -> Float {
  if code == 48 { Float::from_int(0) }
  else if code == 49 { Float::from_int(1) }
  else if code == 50 { Float::from_int(2) }
  else if code == 51 { Float::from_int(3) }
  else if code == 52 { Float::from_int(4) }
  else if code == 53 { Float::from_int(5) }
  else if code == 54 { Float::from_int(6) }
  else if code == 55 { Float::from_int(7) }
  else if code == 56 { Float::from_int(8) }
  else if code == 57 { Float::from_int(9) }
  else { Float::from_int(0) }
}
