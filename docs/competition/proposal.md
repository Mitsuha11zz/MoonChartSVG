# MoonChartSVG 项目申报书

| 项目 | 内容 |
|---|---|
| 项目名称 | MoonChartSVG：纯 MoonBit SVG 图表生成库 |
| GitHub | https://github.com/Mitsuha11zz/MoonChartSVG |
| GitLink | https://gitlink.org.cn/Mitsuha/MoonChartSVG |
| Mooncakes 模块 | `Mitsuha11zz/MoonChartSVG` |
| 项目方向 | MoonBit 工具库 / 数据可视化 |
| 项目性质 | 原创项目，Apache-2.0 |

## 项目简介
MoonChartSVG 使用纯 MoonBit 将结构化数据渲染为独立 SVG，面向报表生成、Wasm 前端、数据分析和教学演示。项目采用不可变 Builder API，不依赖浏览器 Canvas 或第三方运行时。

## 核心功能
- 支持柱状图、折线图、面积图、散点图、饼图、环形图、雷达图、堆叠柱状图和水平柱状图。
- 提供坐标轴缩放、主题与调色板、响应式图例、XML 转义、CSV 解析、统计函数、HTML 包装和仪表盘组合。
- 正确处理整圆 SVG 弧线、非正切片、空统计输入、带引号 CSV、极大/极小坐标轴范围和 Builder 数组隔离。

## 实施与交付
- 维护统一渲染基础设施和九类图表实现，补充可运行 CLI 与文档示例。
- 使用 GitHub Actions 执行 `moon check`、格式检查、`moon info`、四后端测试和覆盖率分析。
- 当前规模为 25 个 MoonBit 文件、约 5,280 行、93 个测试；模块版本为 `0.1.7`。
- 交付公开源码、Apache-2.0 许可证、README、开发报告、验收清单、申报书 PDF 和 Mooncakes 包。

## 独立价值
项目针对 MoonBit 多后端与字符串生成场景设计，不声称替代成熟图表框架；其价值在于提供可复用、零运行时依赖、可在 MoonBit 项目中直接安装的 SVG 可视化基础库。
