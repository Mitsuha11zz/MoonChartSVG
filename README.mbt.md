# MoonChartSVG

MoonChartSVG is a zero-dependency SVG chart library written in pure MoonBit.
It supports bar, line, area, scatter, pie, donut, radar, stacked bar, and
horizontal bar charts.

## Install

```bash
moon add Mitsuha11zz/MoonChartSVG
```

## Checked Example

```mbt check
///|
test "render a standalone SVG chart" {
  let svg = @MoonChartSVG.BarChart::new()
    .title("Monthly Sales")
    .x_labels(["Jan", "Feb", "Mar"])
    .series(@MoonChartSVG.Series::new("Sales", [120.0, 200.0, 150.0]))
    .render()
  assert_eq(svg.has_prefix("<svg"), true)
  assert_eq(svg.has_suffix("</svg>"), true)
}
```

## Highlights

- Consistent builder API for nine chart types
- Pure SVG output with no runtime dependency
- Automatic axis scaling and built-in themes
- Multi-row legends for narrow canvases
- Correct pie, donut, and radar coordinates in every quadrant
- Complete-circle pie and donut paths compatible with SVG renderers
- XML escaping for user-provided labels and attributes
- Defensive array copies for predictable builder semantics
- Quoted CSV parsing, safe empty statistics, HTML wrappers, and dashboards

## Demo

```bash
moon run cmd/main
```

## Validation

```bash
moon check --deny-warn --target all
moon fmt --check
moon info --target all
moon test --deny-warn --target all
moon coverage analyze
```

Non-positive pie and donut slices are ignored, zero totals render without
invalid coordinates, and donut hole ratios are clamped to `0.0..0.95`.
The current suite contains 93 tests.

## License

Apache-2.0
