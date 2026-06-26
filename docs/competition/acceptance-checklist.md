# MoonChartSVG — Competition Acceptance Checklist

## Core Features

### BarChart (柱状图)
- [x] `BarChart::new()` — create with defaults (800x400)
- [x] `title(t)` / `x_labels(labels)` / `series(s)` — builder methods
- [x] `width(w)` / `height(h)` / `config(c)` — configuration
- [x] `render()` — generate complete SVG with grouped bars
- [x] Multi-series support with side-by-side bars
- [x] Auto Y-axis scaling with nice tick intervals
- [x] X-axis category labels
- [x] Legend for multi-series charts

### LineChart (折线图)
- [x] `LineChart::new()` — create with defaults
- [x] Builder methods: `title()`, `x_labels()`, `series()`, `width()`, `height()`, `config()`
- [x] `render()` — generate SVG with polylines + circle markers
- [x] Multi-series support
- [x] Bounds checking between x_labels and series values

### PieChart (饼图)
- [x] `PieChart::new()` — create with defaults (500x400)
- [x] Builder methods: `title()`, `slice(name, value)`, `width()`, `height()`
- [x] `render()` — generate SVG arc paths with percentage labels
- [x] Taylor series sin/cos for SVG arc computation

### ScatterChart (散点图)
- [x] Builder + render with circle markers
- [x] X/Y axis labels, configurable point size

### RadarChart (雷达图)
- [x] Multi-axis radar with concentric grid polygons
- [x] Multi-series filled polygon overlay
- [x] Axis labels at perimeter
- [x] Configurable grid levels

### AreaChart (面积图)
- [x] Filled polygon under line + polyline overlay
- [x] Multi-series support
- [x] Circle markers at data points

### StackedBarChart (堆叠柱状图)
- [x] Vertical stacking per category
- [x] Y-axis based on category total sum
- [x] Multi-series, per-segment coloring

### HorBarChart (水平柱状图)
- [x] Horizontal bars with left-to-right layout
- [x] Custom compute_horiz_axis for value axis
- [x] Category labels on Y-axis

### DonutChart (环形图)
- [x] Pie chart with configurable hole_ratio
- [x] Donut segment arc paths (inner + outer radius)
- [x] Total value display in center

## Infrastructure

### ChartConfig
- [x] Custom colors array (fallback to Tableau 10)
- [x] `show_grid` toggle
- [x] `title_font_size`, `axis_font_size`, `legend_font_size`

### Axes
- [x] `compute_y_axis()` — auto-range with nice_step algorithm
- [x] `y_to_svg()` / `x_to_svg()` — coordinate mapping
- [x] `nice_step()` — 1-2-5 × 10^n pattern

### Color
- [x] Tableau 10 professional palette
- [x] `get_color(index)` — modulo cycling
- [x] `get_chart_color(config, index)` — custom or default

### SVG Util
- [x] `svg_open()` / `svg_close()` — document wrapper
- [x] `rect()`, `text()`, `line()` — basic shapes
- [x] `polyline()`, `circle()`, `path()` — line/point/arc elements
- [x] `polygon()` — filled polygon for area/radar charts

### Data Stats
- [x] `sum()`, `mean()`, `min_value()`, `max_value()`
- [x] `median()` — with insertion sort
- [x] `std_dev()` — with Newton sqrt approximation
- [x] `sort_asc()` — pure functional insertion sort

### CSV Reader
- [x] `parse_csv(content)` — header + rows
- [x] `parse_csv_to_series()` — auto-convert to Series
- [x] `parse_float_or_zero()` — handles int, decimal, negative

### Demo
- [x] 7 demo chart generators (bar, line, pie, scatter, radar, area, dashboard)
- [x] CLI main with demo output

## Project Quality
- [x] `moon check` passes with 0 errors
- [x] `moon test` — 60 tests, all passing
- [x] CI configuration (`.github/workflows/ci.yml`)
- [x] README with installation, quick start, and API reference
- [x] Apache-2.0 License
- [x] GitHub repo: https://github.com/Mitsuha11zz/MoonChartSVG
- [x] GitLink repo: https://gitlink.org.cn/Mitsuha/MoonChartSVG

## Code Statistics
- Chart implementations (9 types): 2,637 lines
- Infrastructure (axes/color/config/legend/svg_util): 283 lines
- Tools (csv_reader/data_stats/demo): 502 lines
- Tests: 546 lines
- Demo/CLI/config: 79 lines
- Total: 4,047 lines

## Competition Submission
- [x] GitHub repository pushed (20 commits)
- [x] GitLink mirror pushed
- [x] 10-20 meaningful commits (20)
- [x] Project proposal PDF generated
