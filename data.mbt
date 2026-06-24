pub(all) struct Series {
  name : String
  values : Array[Float]
}

pub fn Series::new(name : String, values : Array[Float]) -> Series {
  { name, values }
}

pub(all) struct Slice {
  name : String
  value : Float
}

pub fn Slice::new(name : String, value : Float) -> Slice {
  { name, value }
}
