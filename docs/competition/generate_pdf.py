"""Generate the one-page MoonChartSVG competition proposal PDF."""

import os
import shutil

from fpdf import FPDF


SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
FONT_PATH = os.path.join(SCRIPT_DIR, "font.ttc")
OUTPUT_PATH = os.path.join(SCRIPT_DIR, "MoonChartSVG项目申报书.pdf")


def ensure_font():
    if os.path.exists(FONT_PATH):
        return
    for candidate in (
        "C:/Windows/Fonts/msyh.ttc",
        "C:/Windows/Fonts/msyhbd.ttc",
        "C:/Windows/Fonts/simsun.ttc",
        "C:/Windows/Fonts/simhei.ttf",
    ):
        if os.path.exists(candidate):
            shutil.copy(candidate, FONT_PATH)
            return
    raise RuntimeError("No Chinese font was found")


class ProposalPdf(FPDF):
    def section(self, title):
        self.ln(1)
        self.set_font("F", "B", 10)
        self.set_text_color(30, 64, 120)
        self.cell(0, 5, title, new_x="LMARGIN", new_y="NEXT")
        self.set_draw_color(30, 64, 120)
        self.line(self.l_margin, self.get_y(), self.w - self.r_margin, self.get_y())
        self.ln(1)

    def body(self, text):
        self.set_font("F", "", 7.5)
        self.set_text_color(50, 50, 50)
        self.multi_cell(0, 3.8, text, new_x="LMARGIN", new_y="NEXT")

    def bullet(self, text):
        self.set_font("F", "", 7.2)
        self.set_text_color(55, 55, 55)
        self.multi_cell(
            0,
            3.7,
            "- " + text,
            new_x="LMARGIN",
            new_y="NEXT",
        )

    def info(self, label, value):
        self.set_font("F", "B", 7.5)
        self.cell(29, 4, label + "：")
        self.set_font("F", "", 7.5)
        self.cell(0, 4, value, new_x="LMARGIN", new_y="NEXT")


ensure_font()
pdf = ProposalPdf()
pdf.add_font("F", fname=FONT_PATH)
pdf.add_font("F", "B", fname=FONT_PATH)
pdf.set_auto_page_break(auto=False)
pdf.set_margins(18, 12, 18)
pdf.add_page()

pdf.set_fill_color(30, 64, 120)
pdf.rect(pdf.l_margin, pdf.get_y(), pdf.w - pdf.l_margin - pdf.r_margin, 2, style="F")
pdf.ln(4)
pdf.set_font("F", "B", 16)
pdf.set_text_color(30, 64, 120)
pdf.cell(0, 7, "MoonChartSVG 项目申报书", align="C", new_x="LMARGIN", new_y="NEXT")
pdf.set_font("F", "", 8)
pdf.set_text_color(110, 110, 110)
pdf.cell(
    0,
    5,
    "MoonBit 数据可视化工具库 | 版本 0.1.7",
    align="C",
    new_x="LMARGIN",
    new_y="NEXT",
)

pdf.section("一、基本信息")
pdf.info("GitHub", "https://github.com/Mitsuha11zz/MoonChartSVG")
pdf.info("GitLink", "https://gitlink.org.cn/Mitsuha/MoonChartSVG")
pdf.info("Mooncakes 模块", "Mitsuha11zz/MoonChartSVG")
pdf.info("项目性质", "原创项目，Apache-2.0")

pdf.section("二、项目目标")
pdf.body(
    "MoonChartSVG 使用纯 MoonBit 将结构化数据渲染为独立 SVG，面向报表生成、"
    "Wasm 前端、数据分析和教学演示。项目采用不可变 Builder API，不依赖浏览器 "
    "Canvas 或第三方运行时。"
)

pdf.section("三、核心能力")
for item in (
    "支持柱状图、折线图、面积图、散点图、饼图、环形图、雷达图、堆叠柱状图和水平柱状图。",
    "提供通用坐标轴缩放、主题、调色板、响应式图例、XML 转义、HTML 包装和仪表盘组合。",
    "CSV 支持引号字段、转义引号、嵌入换行和 CRLF；统计函数覆盖空输入边界。",
    "整圆饼图/环形图采用多段 SVG 圆弧，三角函数与坐标测试覆盖全部象限。",
):
    pdf.bullet(item)

pdf.section("四、工程证据")
for item in (
    "25 个 MoonBit 文件，约 5,280 行；9 种图表；93 个测试；37 次已有提交。",
    "CI 执行 moon check、moon fmt --check、moon info、四后端 moon test 和覆盖率分析。",
    "提供 README、可执行文档测试、CLI 演示、开发报告、验收清单和一页式申报书。",
):
    pdf.bullet(item)

pdf.section("五、独立价值与交付")
pdf.body(
    "项目针对 MoonBit 多后端和字符串生成场景设计，目标是提供可安装、可复用、"
    "零运行时依赖的 SVG 可视化基础库，不声称替代成熟图表框架。交付物包括公开源码、"
    "Apache-2.0 许可证、Mooncakes 包、测试、CI、示例和比赛文档。"
)

pdf.section("六、已知边界")
pdf.body(
    "当前输出为静态 SVG；尚未实现浏览器端动画、通用标签碰撞检测和组合图表。"
    "这些能力列为后续规划，不作为当前已完成成果。"
)

pdf.output(OUTPUT_PATH)
print(f"Done: {OUTPUT_PATH}")
