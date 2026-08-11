# MoonChartSVG 开发报告

## 1. 项目目标

MoonChartSVG 是一个纯 MoonBit SVG 图表生成库。用户通过 Builder API 提供数据和样式，`render()` 返回可直接保存、嵌入 HTML 或用于 Wasm 页面展示的独立 SVG 字符串。

项目当前支持 9 种图表：柱状图、折线图、面积图、散点图、饼图、环形图、雷达图、堆叠柱状图和水平柱状图。

## 2. 架构

```text
Series / Slice / CSV
        |
        v
Chart Builder -> layout/axis/legend -> SVG primitives -> standalone SVG
```

| 层次 | 主要文件 | 职责 |
|---|---|---|
| 数据与配置 | `data.mbt`, `config.mbt`, `theme.mbt`, `palette.mbt` | 数据模型、主题和颜色 |
| 布局 | `axes.mbt`, `legend.mbt` | 坐标轴、刻度和图例布局 |
| 渲染 | `svg_util.mbt` | SVG 元素、属性和 XML 转义 |
| 图表 | 9 个 `*chart.mbt` 文件 | 各图表布局和渲染 |
| 集成 | `csv_reader.mbt`, `data_stats.mbt`, `html_wrapper.mbt`, `demo.mbt` | 数据导入、统计、HTML 和示例 |

Builder 方法复制外部数组后返回新值，避免调用方后续修改数组时改变已构建图表。

## 3. 核心实现

### 3.1 SVG 几何

饼图、环形图和雷达图使用角度归约后的 Taylor 近似计算三角函数。测试覆盖四个象限，并验证生成坐标不会出现 `NaN`。100% 单切片不能使用起终点重合的一条 SVG 圆弧，因此饼图使用两个半圆弧，环形图使用四条内外半圆弧。

### 3.2 坐标轴

坐标轴步长采用通用 `1/2/5 x 10^n` 归一化算法，不再局限于固定数值表，可处理小数范围和较大数量级。正负数据通过统一的 `y_to_svg` 映射进入绘图区。

### 3.3 CSV 与统计边界

CSV 解析器使用状态机处理普通字段、引号字段和引号结束状态，支持字段内逗号、转义双引号、嵌入换行与 CRLF。数字解析支持前后空白、正负号和科学计数法。

统计函数对空数组统一返回 `0.0`，避免均值和标准差除零，以及最值函数访问空数组。该行为已写入 README 并由测试固定。

### 3.4 输出安全

SVG 文本和属性经过 XML 转义；HTML 标题同样转义。图例按画布宽度自动换行，Builder 对输入数组执行防御性复制。

## 4. 工程质量

| 指标 | 当前值 |
|---|---:|
| MoonBit 文件 | 25 |
| MoonBit 总行数 | 5,280 |
| 图表实现 | 3,036 行 |
| 基础设施 | 594 行 |
| 工具与集成 | 762 行 |
| 测试与可执行文档 | 886 行 |
| 测试数量 | 93 |
| 已有提交 | 30+ 次有效提交 |
| 模块版本 | 0.1.7 |

本地质量门禁：

```bash
moon check --deny-warn --target all
moon fmt --check
moon info --target all
moon test --deny-warn --target all
moon coverage analyze
moon run cmd/main
```

当前 MoonBit CLI 不接受 `moon fmt --deny-warn` 或 `moon info --deny-warn`。项目使用 `moon fmt --check` 和无警告的 `moon info --target all` 作为当前工具链支持的等价门禁，并在 CI 与 README 中明确说明。

## 5. 已知边界与后续计划

- 当前输出为静态 SVG，不包含浏览器端动画或交互运行时。
- CSV 采用宽松解析策略，未闭合引号会保留已读取内容，不提供严格错误对象和源码位置。
- 标签碰撞目前通过固定边距与图例换行缓解，尚未实现通用文本测量。
- 后续可增加柱线组合图、`viewBox`/无障碍元数据、统一布局引擎和基于 `StringBuilder` 的流式渲染。

这些边界在材料中明确披露，不将尚未实现的能力写作已完成成果。
