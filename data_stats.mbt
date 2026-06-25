/// Data Statistics Module
/// Utility functions for computing statistical properties of Float arrays.

pub fn sum(values : Array[Float]) -> Float {
  fn aux(idx : Int, acc : Float) -> Float {
    if idx >= values.length() {
      acc
    } else {
      aux(idx + 1, acc + values[idx])
    }
  }
  aux(0, 0.0)
}

pub fn mean(values : Array[Float]) -> Float {
  sum(values) / Float::from_int(values.length())
}

pub fn min_value(values : Array[Float]) -> Float {
  fn aux(idx : Int, current_min : Float) -> Float {
    if idx >= values.length() {
      current_min
    } else if values[idx] < current_min {
      aux(idx + 1, values[idx])
    } else {
      aux(idx + 1, current_min)
    }
  }
  aux(1, values[0])
}

pub fn max_value(values : Array[Float]) -> Float {
  fn aux(idx : Int, current_max : Float) -> Float {
    if idx >= values.length() {
      current_max
    } else if values[idx] > current_max {
      aux(idx + 1, values[idx])
    } else {
      aux(idx + 1, current_max)
    }
  }
  aux(1, values[0])
}

// Append remaining elements from source[from..] into target
fn append_rest(source : Array[Float], from : Int, target : Array[Float]) -> Unit {
  if from < source.length() {
    target.push(source[from])
    append_rest(source, from + 1, target)
  }
}

// Insert a value into an already-sorted array in ascending order
fn insert_sorted(sorted : Array[Float], value : Float) -> Array[Float] {
  fn aux(idx : Int, result : Array[Float]) -> Array[Float] {
    if idx >= sorted.length() {
      result.push(value)
      result
    } else if sorted[idx] > value {
      result.push(value)
      append_rest(sorted, idx, result)
      result
    } else {
      result.push(sorted[idx])
      aux(idx + 1, result)
    }
  }
  aux(0, [])
}

// Recursively build a sorted array from unsorted input
fn build_sorted(unsorted : Array[Float], idx : Int, sorted : Array[Float]) -> Array[Float] {
  if idx >= unsorted.length() {
    sorted
  } else {
    let new_sorted = insert_sorted(sorted, unsorted[idx])
    build_sorted(unsorted, idx + 1, new_sorted)
  }
}

pub fn sort_asc(values : Array[Float]) -> Array[Float] {
  build_sorted(values, 0, [])
}

pub fn median(values : Array[Float]) -> Float {
  let sorted = sort_asc(values)
  let n = sorted.length()
  if n == 0 {
    0.0
  } else if n % 2 == 0 {
    let mid = n / 2
    (sorted[mid - 1] + sorted[mid]) / 2.0
  } else {
    sorted[n / 2]
  }
}

// Newton's method square root approximation
fn sqrt_iter(val : Float, guess : Float, iter : Int) -> Float {
  if iter <= 0 {
    guess
  } else {
    let new_guess = (guess + val / guess) / 2.0
    sqrt_iter(val, new_guess, iter - 1)
  }
}

fn sqrt_approx(x : Float) -> Float {
  if x <= 0.0 {
    0.0
  } else {
    sqrt_iter(x, x / 2.0, 10)
  }
}

pub fn std_dev(values : Array[Float]) -> Float {
  let m = mean(values)
  let n = values.length()

  fn sum_sq_diff(idx : Int, acc : Float) -> Float {
    if idx >= n {
      acc
    } else {
      let diff = values[idx] - m
      sum_sq_diff(idx + 1, acc + diff * diff)
    }
  }

  let variance = sum_sq_diff(0, 0.0) / Float::from_int(n)
  sqrt_approx(variance)
}
