# MoonChartSVG 开发报告

## 开发过程

本项目从零开始构建了一个完整的 MoonBit SVG 图表生成库。开发采用 Builder 模式设计 API，所有图表类型通过链式调用完成配置后调用 `render()` 生成 SVG 字符串输出。

开发分为三个阶段：
1. **基础架构阶段**：实现 Level 枚举、数据模型、SVG 工具函数、坐标轴布局计算
2. **图表实现阶段**：依次实现柱状图、折线图、饼图，然后扩展散点图、雷达图、面积图、堆叠柱状图、水平柱状图、环形图共 9 种图表
3. **功能完善阶段**：添加 ChartConfig 配置系统、CSV 数据解析、Demo CLI、Format 模块

## 架构设计

```
用户 API 调用 -> Chart 结构体 -> Layout 计算（坐标映射/轴刻度）-> Render 生成 SVG 字符串
```

模块划分（24 个文件）：

| 层 | 模块 | 职责 |
|----|------|------|
| 数据 | data.mbt, config.mbt, color.mbt | Series/Slice 类型、ChartConfig 配置、调色板 |
| 布局 | axes.mbt, legend.mbt | Y轴自动刻度计算、坐标映射、图例渲染 |
| 渲染 | svg_util.mbt | SVG 标签构建（rect/text/line/polyline/circle/path/polygon） |
| 图表 | barchart/linechart/piechart/scatter/radar/area/stackedbar/horbar/donut | 9 种图表的完整实现 |
| 工具 | csv_reader.mbt, data_stats.mbt, demo.mbt | CSV 解析、数据统计、演示图表 |

采用不可变 Builder 模式，每个配置方法返回新的 Chart 实例，render() 方法通过递归辅助函数拼接 SVG 字符串。

## 技术难点

### 1. MoonBit 不可变字符串的递归方案
MoonBit 中字符串不可变且不支持 `var` 可变局部变量，传统的 for 循环累加字符串无法实现。解决方案是使用递归辅助函数，通过参数传递累加结果：
```
fn render_bars(result, idx, max) -> String { ... }
```

### 2. SVG 弧线计算 — 三角函数替代
饼图需要 sin/cos 计算弧线端点。MoonBit 标准库中 `@math` 包的三角函数不可用，采用 Taylor 级数近似实现 sin/cos 函数（4 阶展开），精度满足 SVG 渲染需求。

### 3. Float 与 Double 类型混淆
MoonBit 中 `Float` 和 `Double` 是独立类型，字面量 `0.0` 默认推断为 `Double`。需要在 Float 上下文中使用 `Float::from_int(0)` 或用 `: Float` 显式标注类型。

### 4. 跨包可见性管理
外部包只能访问 `pub(all)` 标记的类型和函数。`pub fn` 仅包内可见。在 cmd/main Demo 开发中，需要仔细管理 pub(all) 与 pub 的边界。

## 测试情况

- 60 个测试全部通过
- 测试类型：白盒测试（45个）+ 黑盒测试（15个）
- 覆盖范围：每种图表类型的基本渲染、多系列、空数据边界情况、格式化输出、配置选项

## 项目统计

| 指标 | 数值 |
|------|------|
| 源码 | 4,047 行 |
| 文件数 | 24 个 |
| 图表类型 | 9 种 |
| 测试数 | 60 |
| 提交数 | 20+ |

## 不足与展望

1. **代码量**：组合图表（如柱状图+折线图叠加）暂未支持
2. **交互性**：仅输出静态 SVG，不支持交互/动画
3. **实时渲染**：不支持流式数据/实时更新
4. **更多格式**：可扩展 PNG 输出（通过外部渲染器）
