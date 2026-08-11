// CSV Reader -- Parse comma-separated data with headers.
//
// Supports quoted fields, escaped quotes, embedded commas/newlines, and
// both LF and CRLF record separators.

///|
priv enum CsvState {
  Unquoted
  Quoted
  AfterQuote
}

///|
fn push_csv_field(row : Array[String], field : StringBuilder) -> StringBuilder {
  row.push(field.to_string())
  StringBuilder()
}

///|
fn push_csv_record(
  records : Array[Array[String]],
  row : Array[String],
) -> Array[String] {
  if !(row.length() == 1 && row[0] == "") {
    records.push(row)
  }
  []
}

///|
fn parse_csv_records(content : String) -> Array[Array[String]] {
  let records : Array[Array[String]] = []
  let mut row : Array[String] = []
  let mut field = StringBuilder()
  let mut state = CsvState::Unquoted
  let mut ended_with_record_separator = false

  for ch in content {
    match state {
      Unquoted =>
        match ch {
          ',' => {
            field = push_csv_field(row, field)
            ended_with_record_separator = false
          }
          '\n' => {
            field = push_csv_field(row, field)
            row = push_csv_record(records, row)
            ended_with_record_separator = true
          }
          '\r' => ()
          '"' =>
            if field.to_string() == "" {
              state = Quoted
              ended_with_record_separator = false
            } else {
              field.write_char(ch)
              ended_with_record_separator = false
            }
          _ => {
            field.write_char(ch)
            ended_with_record_separator = false
          }
        }
      Quoted =>
        if ch == '"' {
          state = AfterQuote
        } else {
          field.write_char(ch)
        }
      AfterQuote =>
        match ch {
          '"' => {
            field.write_char('"')
            state = Quoted
            ended_with_record_separator = false
          }
          ',' => {
            field = push_csv_field(row, field)
            state = Unquoted
            ended_with_record_separator = false
          }
          '\n' => {
            field = push_csv_field(row, field)
            row = push_csv_record(records, row)
            state = Unquoted
            ended_with_record_separator = true
          }
          '\r' => ()
          ' ' | '\t' => ()
          _ => {
            field.write_char(ch)
            state = Unquoted
            ended_with_record_separator = false
          }
        }
    }
  }

  if !ended_with_record_separator || row.length() > 0 {
    ignore(push_csv_field(row, field))
    ignore(push_csv_record(records, row))
  }
  records
}

// Parse CSV text into (headers, rows)

///|
pub fn parse_csv(content : String) -> (Array[String], Array[Array[String]]) {
  let records = parse_csv_records(content)
  if records.length() == 0 {
    ([], [])
  } else {
    let headers = records[0]
    let rows : Array[Array[String]] = []
    for i = 1; i < records.length(); i = i + 1 {
      rows.push(records[i])
    }
    (headers, rows)
  }
}

// Parse CSV with numeric values, returning labels and Series objects.
// Headers: "Label,Series1Name,Series2Name,..."
// First column = category labels, remaining columns = data series.

///|
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

///|
pub fn parse_float_or_zero(s : String) -> Float {
  let trimmed = s.trim().to_owned()
  let len = trimmed.length()
  if len == 0 {
    Float::from_int(0)
  } else {
    parse_float_impl(trimmed, 0, len)
  }
}

///|
fn parse_float_impl(s : String, i : Int, len : Int) -> Float {
  // Check for negative sign
  let pair : (Float, Int) = if i < len && s[i] == 45 {
    (-1.0, i + 1)
  } else if i < len && s[i] == 43 {
    (1.0, i + 1)
  } else {
    (1.0, i)
  }
  let sign = pair.0
  let start = pair.1
  let (int_val, after_int) = parse_int_digits(s, start, len, 0.0)
  if after_int < len && s[after_int] == 46 {
    let (frac_val, after_frac) = parse_frac_digits(
      s,
      after_int + 1,
      len,
      0.0,
      0.1,
    )
    apply_exponent(s, after_frac, len, sign * (int_val + frac_val))
  } else {
    apply_exponent(s, after_int, len, sign * int_val)
  }
}

///|
fn apply_exponent(s : String, i : Int, len : Int, value : Float) -> Float {
  if i >= len || (s[i] != 69 && s[i] != 101) {
    value
  } else {
    let sign_and_start : (Int, Int) = if i + 1 < len && s[i + 1] == 45 {
      (-1, i + 2)
    } else if i + 1 < len && s[i + 1] == 43 {
      (1, i + 2)
    } else {
      (1, i + 1)
    }
    let (exponent, after_exponent) = parse_int_digits(
      s,
      sign_and_start.1,
      len,
      0.0,
    )
    if after_exponent == sign_and_start.1 {
      value
    } else {
      scale_by_power10(value, sign_and_start.0 * exponent.to_int())
    }
  }
}

///|
fn scale_by_power10(value : Float, exponent : Int) -> Float {
  let mut result = value
  let mut remaining = if exponent < 0 { -exponent } else { exponent }
  while remaining > 0 {
    result = if exponent < 0 { result / 10.0 } else { result * 10.0 }
    remaining = remaining - 1
  }
  result
}

// Parse a sequence of digit characters into a Float value.
// Returns (accumulated value, next index).

///|
fn parse_int_digits(
  s : String,
  i : Int,
  len : Int,
  acc : Float,
) -> (Float, Int) {
  if i >= len {
    (acc, i)
  } else {
    let ch = s[i] // UInt16 character code
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

///|
fn parse_frac_digits(
  s : String,
  i : Int,
  len : Int,
  acc : Float,
  place : Float,
) -> (Float, Int) {
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

///|
fn code_to_float(code : UInt16) -> Float {
  if code == 48 {
    Float::from_int(0)
  } else if code == 49 {
    Float::from_int(1)
  } else if code == 50 {
    Float::from_int(2)
  } else if code == 51 {
    Float::from_int(3)
  } else if code == 52 {
    Float::from_int(4)
  } else if code == 53 {
    Float::from_int(5)
  } else if code == 54 {
    Float::from_int(6)
  } else if code == 55 {
    Float::from_int(7)
  } else if code == 56 {
    Float::from_int(8)
  } else if code == 57 {
    Float::from_int(9)
  } else {
    Float::from_int(0)
  }
}
