"""Generate MoonChartSVG proposal PDF — one-page compact style."""
from fpdf import FPDF
import os

# Use local font copy to avoid path encoding issues
script_dir = os.path.dirname(os.path.abspath(__file__))
local_font = os.path.join(script_dir, "font.ttc")

if not os.path.exists(local_font):
    # Copy system font to local
    for fp in [
        "C:/Windows/Fonts/msyh.ttc",
        "C:/Windows/Fonts/msyhbd.ttc",
        "C:/Windows/Fonts/simsun.ttc",
        "C:/Windows/Fonts/simhei.ttf",
    ]:
        if os.path.exists(fp):
            import shutil
            shutil.copy(fp, local_font)
            break

if not os.path.exists(local_font):
    print("ERROR: No Chinese font found!")
    exit(1)

class PDF(FPDF):
    def __init__(self):
        super().__init__()
        self.add_font("F", fname=local_font)
        self.add_font("F", "B", fname=local_font)

    def header(self):
        pass

    def footer(self):
        pass

    def title_line(self):
        self.set_fill_color(30, 64, 120)
        self.rect(self.l_margin, self.get_y(), self.w - self.l_margin - self.r_margin, 2, style="F")
        self.ln(4)
        self.set_font("F", "B", 16)
        self.set_text_color(30, 64, 120)
        self.cell(0, 7, "MoonChartSVG 项目申报书", align="C", new_x="LMARGIN", new_y="NEXT")
        self.set_font("F", "", 8)
        self.set_text_color(130, 120, 105)
        self.cell(0, 5, "2026 MoonBit 国产开源生态竞赛（个人赛）", align="C", new_x="LMARGIN", new_y="NEXT")
        self.ln(2)

    def sec(self, num, title):
        self.ln(1)
        self.set_font("F", "B", 10)
        self.set_text_color(30, 64, 120)
        self.cell(0, 5, f"{num}、{title}", new_x="LMARGIN", new_y="NEXT")
        self.set_draw_color(30, 64, 120)
        self.set_line_width(0.2)
        self.line(self.l_margin, self.get_y(), self.w - self.r_margin, self.get_y())
        self.ln(1.5)

    def body(self, text):
        self.set_font("F", "", 7.5)
        self.set_text_color(55, 55, 55)
        self.multi_cell(0, 3.8, text, align="L")

    def bullet(self, text):
        self.set_font("F", "", 7)
        self.set_text_color(65, 65, 65)
        self.cell(3, 3.6, "")
        self.cell(0, 3.6, "- " + text, new_x="LMARGIN", new_y="NEXT")

    def info(self, label, value):
        self.set_font("F", "B", 7.5)
        self.set_text_color(60, 60, 60)
        self.cell(28, 4.2, label + "：")
        self.set_font("F", "", 7.5)
        self.set_text_color(50, 50, 50)
        self.cell(0, 4.2, value, new_x="LMARGIN", new_y="NEXT")

    def sub(self, title):
        self.set_font("F", "B", 8)
        self.set_text_color(30, 64, 120)
        self.cell(0, 4.5, title, new_x="LMARGIN", new_y="NEXT")

    def t_header(self, cells, widths):
        self.set_fill_color(30, 64, 120)
        self.set_text_color(255, 255, 255)
        self.set_font("F", "B", 7)
        h = 5
        for cell, w in zip(cells, widths):
            x = self.get_x()
            self.rect(x, self.get_y(), w, h, style="F")
            self.cell(w, h, " " + cell)
        self.ln(h)

    def t_row(self, cells, widths, bold=False):
        if bold:
            self.set_fill_color(235, 242, 250)
            self.set_font("F", "B", 7)
        else:
            self.set_fill_color(255, 255, 255)
            self.set_font("F", "", 7)
        self.set_text_color(50, 50, 50)
        h = 4.8
        for cell, w in zip(cells, widths):
            x = self.get_x()
            self.rect(x, self.get_y(), w, h, style="DF")
            self.cell(w, h, " " + cell)
        self.ln(h)


pdf = PDF()
pdf.set_auto_page_break(auto=False)
pdf.add_page()

pdf.title_line()

# ===== 一 =====
pdf.sec("一", "基本信息")
pdf.info("项目名称", "MoonChartSVG：纯 MoonBit SVG 图表生成库")
pdf.info("GitHub", "https://github.com/Mitsuha11zz/MoonChartSVG")
pdf.info("GitLink", "https://gitlink.org.cn/Mitsuha/MoonChartSVG")
pdf.info("项目方向", "MoonBit 工具库 / 数据可视化")
pdf.info("原创/移植", "原创项目")
pdf.info("许可证", "Apache-2.0")

# ===== 二 =====
pdf.sec("二", "项目简介")
pdf.body(
    "MoonChartSVG 是一个纯 MoonBit 实现的 SVG 图表生成库，通过 Builder API 将结构化数据直接渲染为 SVG 字符串。"
    "支持 9 种图表类型（柱状图、折线图、饼图、散点图、雷达图、面积图、堆叠柱状图、水平柱状图、环形图），"
    "覆盖从基础统计到多维对比的主流可视化需求。零外部依赖，仅依赖 MoonBit 标准库。"
    "MoonBit 生态目前缺乏数据可视化工具，本项目填补了这一空白。"
)

# ===== 三 =====
pdf.sec("三", "核心功能范围")

pdf.sub("图表类型（9种）")
pdf.t_header(["图表", "文件", "行数", "核心特性"], [32, 36, 20, 58])
for row in [
    ("BarChart 柱状图", "barchart.mbt", "333", "分组柱状图，多系列并排，Y轴自动缩放"),
    ("LineChart 折线图", "linechart.mbt", "358", "多系列折线+圆圈标记，X轴标签"),
    ("PieChart 饼图", "piechart.mbt", "205", "弧形切片，百分比标注，Taylor级数sin/cos"),
    ("ScatterChart 散点图", "scatter.mbt", "336", "X-Y数据点，可配置点大小，轴标签"),
    ("RadarChart 雷达图", "radar.mbt", "341", "多轴对比，同心网格线，填充多边形"),
    ("AreaChart 面积图", "areachart.mbt", "245", "折线下方填充区域，polygon+polyline叠加"),
    ("StackedBarChart 堆叠柱状图", "stackedbar.mbt", "279", "系列垂直堆叠，按类别总和高计算"),
    ("HorBarChart 水平柱状图", "horbarchart.mbt", "363", "横向柱体，横向坐标轴计算"),
    ("DonutChart 环形图", "donutchart.mbt", "177", "饼图中心镂空，hole_ratio可调"),
]:
    pdf.t_row(row, [32, 36, 20, 58])
pdf.ln(1)

pdf.sub("基础设施与工具模块")
for item in [
    "ChartConfig：全局样式配置（自定义颜色、网格开关、标题/坐标轴/图例字体大小）",
    "Axes：Y轴自动刻度计算（nice step算法，1-2-5×10ⁿ模式）、坐标→像素映射",
    "Color：Tableau 10专业调色板 + 自定义颜色循环，10色规范色值",
    "SVG Util：SVG标签构建器（rect/text/line/polyline/circle/polygon/path），递归字符串拼接",
    "Data Stats：统计工具函数（求和/均值/中位数/标准差/排序），纯函数式插入排序",
    "CSV Reader：CSV文本解析（首行表头+数据行），Series/Slice自动转换",
    "Demo：7套预设演示图表（含Dashboard 1200×900复合布局），覆盖全部图表类型",
]:
    pdf.bullet(item)

# ===== 四 =====
pdf.sec("四", "差异化价值")
pdf.body("MoonBit 生态对比：")
pdf.t_header(["维度", "MoonChartSVG", "MoonBit生态现状"], [24, 55, 67])
for row in [
    ("语言", "MoonBit", "—"),
    ("图表类型", "9种", "无可对标项目"),
    ("依赖", "零外部依赖", "—"),
    ("输出", "纯SVG字符串，Native/Wasm/JS三端", "—"),
    ("API风格", "Builder Pattern 链式调用", "—"),
    ("生态定位", "MoonBit首个可视化库，填补空白", "数据可视化方向为零"),
]:
    pdf.t_row(row, [24, 55, 67])
pdf.ln(1)

pdf.body(
    "与 Python matplotlib / JavaScript Chart.js 等成熟工具相比，MoonChartSVG 针对 MoonBit 语言特性设计："
    "不可变Builder模式适配函数式编程，递归辅助函数替代可变状态，纯SVG输出无平台依赖。"
    "MoonBit 生态中数据可视化方向完全空白，本项目具有先发优势。"
)

# ===== 五 =====
pdf.sec("五", "项目规模与进度")

pdf.t_header(["模块", "源码行", "说明"], [48, 24, 90])
for row in [
    ("图表实现（9种）", "2,637", "Bar/Line/Pie/Scatter/Radar/Area/Stacked/Hor/Donut"),
    ("基础设施", "283", "axes/color/config/legend/svg_util"),
    ("工具模块", "502", "csv_reader/data_stats/demo"),
    ("测试代码", "546", "moonchart_test + moonchart_wbtest（60个测试）"),
    ("Demo/CLI/配置", "79", "cmd/main + moonchart.mbt"),
    ("合计", "4,047", "60测试全通过，19次有效提交"),
]:
    pdf.t_row(row, [48, 24, 90], bold=(row[0] == "合计"))
pdf.ln(1)

pdf.body("CI 配置完成（GitHub Actions），README 完整（安装、快速开始、API参考），双仓库推送（GitHub + GitLink）。")

# ===== 六 =====
pdf.sec("六", "适用场景")
pdf.body(
    "数据报表生成（CSV→图表一键生成）| WebAssembly前端可视化（编译为Wasm，浏览器内SVG渲染）| "
    "数据分析管道（Data Stats → Chart 串联）| 算法可视化与教育演示 | "
    "MoonBit 生态工具链（为其他项目提供可视化能力）| "
    "仪表盘系统（Dashboard复合布局，多图表同屏展示）"
)

output_path = os.path.join(os.path.dirname(__file__), "MoonChartSVG项目申报书.pdf")
pdf.output(output_path)
print(f"Done: {output_path}")
