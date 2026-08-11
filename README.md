# MoonChartSVG

MoonChartSVG is a zero-dependency SVG chart library written in pure MoonBit.
It provides builder APIs for bar, line, area, scatter, pie, donut, radar,
stacked bar, and horizontal bar charts.

## Install

```bash
moon add Mitsuha11zz/MoonChartSVG
```

## Quick Start

```moonbit
let svg = @MoonChartSVG.BarChart::new()
  .title("Monthly Sales")
  .x_labels(["Jan", "Feb", "Mar", "Apr"])
  .series(@MoonChartSVG.Series::new("Product A", [120.0, 200.0, 150.0, 180.0]))
  .series(@MoonChartSVG.Series::new("Product B", [80.0, 130.0, 170.0, 140.0]))
  .render()
```

`render()` returns a complete standalone `<svg>` document. It can be written
to a file, embedded in HTML, or composed with the included dashboard helpers.

## Highlights

- Nine chart types with a consistent builder API
- Pure SVG output with no browser or runtime dependency
- Automatic axis scaling and a built-in Tableau-style palette
- Responsive multi-row legends for narrow canvases
- XML escaping for titles, labels, colors, and generated attributes
- Stable pie, donut, and radar coordinates across all angle quadrants
- Defensive copies in builders so earlier chart values stay unchanged
- Graceful handling of empty and non-positive pie or donut data
- CSV parsing, descriptive statistics, themes, and HTML wrappers

## Demo

```bash
moon run cmd/main
```

The command prints complete examples for every chart type, a composed SVG
dashboard, theme usage, and CSV-driven data.

## Validation

```bash
moon check --deny-warn --target all
moon fmt --check
moon info
moon test --deny-warn --target all
```

The current MoonBit CLI does not accept `--deny-warn` for `moon fmt` or
`moon info`; `moon fmt --check` and a clean `moon info` run are the supported
equivalent checks.

## Data Behavior

- Pie and donut slices with values less than or equal to zero are ignored.
- A pie or donut whose positive total is zero renders an empty SVG chart.
- Donut hole ratios are clamped to the range `0.0..0.95`.
- Radar values missing from a series are rendered as zero.
- User-provided SVG text and attributes are XML escaped.

## License

Apache-2.0
