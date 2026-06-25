# MoonChartSVG 项目申报书

## 基本信息

| 项目 | 内容 |
|------|------|
| **项目名称** | MoonChartSVG：纯 MoonBit SVG 图表生成库 |
| **GitHub 仓库** | https://github.com/Mitsuha11zz/MoonChartSVG |
| **GitLink 仓库** | https://gitlink.org.cn/Mitsuha/MoonChartSVG |
| **项目方向** | MoonBit 工具库 / 数据可视化 |
| **是否为移植项目** | 否（原创项目） |
| **许可证** | Apache-2.0 |

## 项目简介

MoonChartSVG 是一个**纯 MoonBit 实现**的 SVG 图表生成库，通过 Builder API 将结构化数据直接渲染为 SVG 字符串。支持 9 种图表类型，覆盖从基础统计到多维对比的主流可视化需求。零外部依赖，仅依赖 MoonBit 标准库和核心数学函数。

MoonBit 生态目前缺乏数据可视化工具，本项目填补了这一空白。用户可通过简洁的链式 API 快速生成专业级图表，适用于报表生成、数据分析、WebAssembly 前端等场景。

## 核心功能范围

### 图表类型（9 种）

| 图表 | 文件 | 说明 |
|------|------|------|
| **柱状图** (BarChart) | barchart.mbt (333行) | 分组柱状图，多系列并排 |
| **折线图** (LineChart) | linechart.mbt (358行) | 多系列折线，数据点标记 |
| **饼图** (PieChart) | piechart.mbt (205行) | 弧形切片，百分比标签 |
| **散点图** (ScatterChart) | scatter.mbt (336行) | X-Y 数据点，可配置点大小 |
| **雷达图** (RadarChart) | radar.mbt (341行) | 多轴对比，多层同心网格 |
| **面积图** (AreaChart) | areachart.mbt (245行) | 折线下方填充区域 |
| **堆叠柱状图** (StackedBarChart) | stackedbar.mbt (279行) | 系列柱体垂直堆叠 |
| **水平柱状图** (HorBarChart) | horbarchart.mbt (363行) | 横向柱体，适合分类对比 |
| **环形图** (DonutChart) | donutchart.mbt (177行) | 饼图中心镂空，支持比例调节 |

### 基础设施模块

| 模块 | 说明 |
|------|------|
| **ChartConfig** | 全局样式配置：自定义颜色、网格开关、字体大小 |
| **Axes** | Y 轴自动刻度计算（nice step 算法）、坐标映射 |
| **Color** | Tableau 10 专业调色板，支持自定义颜色循环 |
| **Legend** | 多系列图例自动渲染 |
| **SVG Util** | SVG 标签构建工具（rect/text/line/polyline/circle/polygon/path） |
| **Data Stats** | 统计工具：求和、均值、中位数、标准差、排序 |
| **CSV Reader** | CSV 数据解析，支持 Series/Slice 自动转换 |
| **Demo** | 7 套预设演示图表，含 Dashboard 复合布局 |

### 工程质量

- 60 个单元测试全部通过
- GitHub Actions CI 持续集成
- 完整 README（中英文、安装、快速开始、API 参考）
- Builder API 设计，链式调用风格
- 纯函数式实现（递归辅助函数，无 var 可变状态）

## 差异化价值

| 对比维度 | MoonChartSVG | 类似项目（图表生成） |
|---------|-------------|-------------------|
| 语言 | MoonBit | Python/JavaScript |
| 依赖 | 零外部依赖 | matplotlib (Python), Chart.js (JS) |
| 输出格式 | 纯 SVG 字符串 | 位图/Canvas/HTML |
| 运行环境 | Native/Wasm/JS 三端 | 单平台 |
| API 风格 | Builder Pattern | 命令式 / 声明式 |
| 生态定位 | 填补 MoonBit 空白 | 成熟生态 |

MoonBit 生态中**不存在可对标项目**，MoonChartSVG 是首个 MoonBit 数据可视化库。

## 项目规模

| 类别 | 行数 |
|------|------|
| 图表实现（9种） | 2,637 |
| 基础设施（axes/color/config/legend/svg_util） | 283 |
| 工具模块（csv_reader/data_stats/demo） | 502 |
| 测试代码 | 546 |
| Demo / CLI / 配置 | 79 |
| **合计** | **4,047** |

项目总计约 **4,047 行** MoonBit 代码，19 次有效提交，60 个测试全部通过。

## 适用场景

- **数据报表生成**：从 CSV 数据一键生成柱状图/折线图/饼图
- **WebAssembly 前端可视化**：MoonBit 编译为 Wasm，在浏览器中直接渲染 SVG
- **数据分析管道**：配合 Data Stats 模块，数据→统计→可视化一条龙
- **教育演示**：算法可视化、数学函数图像、统计分布展示
- **MoonBit 生态工具链**：为其他 MoonBit 项目提供可视化能力
- **仪表盘系统**：Dashboard 复合布局，多图表同时展示
