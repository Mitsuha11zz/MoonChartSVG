# MoonChart

Pure MoonBit SVG chart generation library.

## Features

- **Bar Chart** — grouped bars with multiple series
- **Line Chart** — polylines with data point markers
- **Pie Chart** — arc slices with percentage labels
- **Auto-scaling** — automatic Y-axis range and tick calculation
- **Tableau 10 colors** — professional color palette by default
- **Zero dependencies** — pure MoonBit, SVG string output

## Installation

```
moon add oilleelssq-wq/moonchart
```

## Quick Start

### Bar Chart

```moonbit
let chart = BarChart::new()
  .title("Monthly Sales")
  .x_labels(["Jan", "Feb", "Mar", "Apr"])
  .series(Series::new("Product A", [120.0, 200.0, 150.0, 180.0]))
  .series(Series::new("Product B", [80.0, 130.0, 170.0, 140.0]))
let svg : String = chart.render()
```

### Line Chart

```moonbit
let chart = LineChart::new()
  .title("Revenue Trend")
  .x_labels(["Q1", "Q2", "Q3", "Q4"])
  .series(Series::new("Revenue", [50.0, 80.0, 120.0, 200.0]))
let svg : String = chart.render()
```

### Pie Chart

```moonbit
let chart = PieChart::new()
  .title("Market Share")
  .slice("Desktop", 55.0)
  .slice("Mobile", 35.0)
  .slice("Tablet", 10.0)
let svg : String = chart.render()
```

## API Reference

### Data Types

- `Series::new(name: String, values: Array[Float]) -> Series`
- `Slice::new(name: String, value: Float) -> Slice`

### BarChart / LineChart

| Method | Returns | Description |
|--------|---------|-------------|
| `new()` | Chart | Create with defaults (800x400) |
| `title(t)` | Chart | Set chart title |
| `x_labels(labels)` | Chart | Set X-axis category labels |
| `series(s)` | Chart | Add a data series |
| `width(w)` | Chart | Set chart width |
| `height(h)` | Chart | Set chart height |
| `render()` | String | Generate SVG output |

### PieChart

| Method | Returns | Description |
|--------|---------|-------------|
| `new()` | Chart | Create with defaults (500x400) |
| `title(t)` | Chart | Set chart title |
| `slice(name, value)` | Chart | Add a pie slice |
| `width(w)` | Chart | Set chart width |
| `height(h)` | Chart | Set chart height |
| `render()` | String | Generate SVG output |

## License

Apache-2.0
