# fdu-proposal

<p align="center">
  <img src="assets/readme/hero.svg" width="100%" alt="fdu-proposal：复旦大学研究生学位论文开题报告记录表的 LaTeX 模板，提供四页空白表、完整填写示例、可续页正文与自动参考文献。">
</p>

fdu-proposal 为复旦大学研究生学位论文开题报告记录表提供 LaTeX 排版。文档类依据原始记录表校准页面、表格和签字区域，首页与页脚共用填写信息，正文和表格支持自然续页。

[快速开始](#快速开始) · [填写信息](#填写信息) · [正文与参考文献](#正文与参考文献) · [检查](#检查)

| 模板入口 | 用途 |
| --- | --- |
| [完整填写示例](templates/example.tex) | 正文、公式、自动参考文献、进度表与人员表；身份字段均为占位内容 |
| [四页空白表](templates/main.tex) | 保留原表固定结构，适合打印或核对版式 |
| [fdu-proposal.cls](fdu-proposal.cls) | 文档类维护源码 |

完整示例采用泛函分析与算子理论主题，题为“紧自伴算子的谱逼近与扰动估计”，正文仅用于排版演示。

## 快速开始

环境需要包含中文支持的 TeX 发行版，例如完整的 TeX Live 或 MacTeX，以及 XeLaTeX、`latexmk` 和 Biber。

```sh
git clone https://github.com/xkwxdyy/fdu-proposal.git
cd fdu-proposal
latexmk -xelatex -outdir=build templates/example.tex
```

结果为 `build/example.pdf`。编译空白表时，使用：

```sh
latexmk -xelatex -outdir=build templates/main.tex
```

默认中文字体为发行版自带的 Fandol。原始 PDF 使用的部分字体不属于 TeX 发行版，默认字体的字形与原表存在差异；安装相应字体后，可通过 `fontset` 选项选择其他 CTeX 字体方案。正式提交前，应核对院系当前使用的表格要求。

<details>
<summary>手动编译与编辑器设置</summary>

完整填写示例的编译顺序为 XeLaTeX、Biber、XeLaTeX、XeLaTeX。在项目根目录执行：

```sh
mkdir -p build
xelatex -output-directory=build templates/example.tex
biber --input-directory=build --output-directory=build example
xelatex -output-directory=build templates/example.tex
xelatex -output-directory=build templates/example.tex
```

编辑器应选择 XeLaTeX，并将项目根目录加入 TeX 搜索路径。在线编辑环境应同时包含所选 `.tex` 文件和 `fdu-proposal.cls`；完整示例还需要根目录中的 `references.bib` 与 `gb7714-FDU.cbx`。

</details>

## 填写信息

首页与所有页脚统一读取 `\fppsetup{info={...}}`。未设置的字段保持空白，文档类不保存具体身份、联系方式或活动信息。

| 内容 | 字段 |
| --- | --- |
| 姓名、学号 | `name`、`student-id` |
| 院系、专业、研究方向 | `department`、`major`、`research-area` |
| 导师、培养层次、学位类型 | `supervisor`、`degree-level`、`degree-type` |
| 入学方式、资格考试通过日期 | `admission-method`、`qualification-date` |
| 电话、邮箱 | `phone`、`email` |
| 开题次数、时间、地点 | `proposal-count`、`proposal-date`、`proposal-place` |
| 论文题目、所属学科或专业、选题来源 | `thesis-title`、`discipline`、`topic-source` |
| 专家名单 | `experts` |

首页保持原表的固定行高。较长字段允许换行，并在必要时等比例缩小至单元格内；正式使用前应检查文字是否清晰，过长内容宜适当精简。开题时间可以使用 `\\` 分行。

专家名单每行依次填写姓名、职称、学科或专业、工作单位。名单最多接受十行，每行必须填写四列，缺项使用空单元格保留；末行的 `\\` 可以省略。

```tex
\fppsetup{info={
  experts = {
    专家姓名甲 & 职称 & 学科或专业 & 工作单位 \\
    专家姓名乙 & 职称 & 学科或专业 & 工作单位
  },
}}
```

## 正文与参考文献

`\blankDetails` 输出原表中的空白详情页。填写正文时，采用完整示例中的 `\chapter` 和 `\section` 结构；正文允许自然续页，不限制总页数。续页继续显示外框、姓名和学号，导师意见及专家评议区域保留供填写或签字。

`schedule` 环境固定使用“起讫日期、主要研究内容、预期结果”列。每行使用 `&` 分隔，使用 `\\` 结束；表格按行续页，并重复表头。单元格可以留空，但不能缺少列分隔符。

```tex
\begin{schedule}
  起止时间 & 研究内容 & 预期结果 \\
  起止时间 & 研究内容 & 预期结果
\end{schedule}
```

`assistants` 环境同样使用三列，首行作为表头，并在续页重复。完整示例展示了填写方式；单行内容应控制在一页以内。

参考文献使用 `biblatex + Biber`。类选项 `bibliography` 启用统一样式，[references.bib](references.bib) 保存文献数据，正文使用 `\parencite{文献键}` 或 `\cite{文献键}` 引用，并通过 `\printbibliography` 输出文献表。标题、间距与编号由文档类管理，[gb7714-FDU.cbx](gb7714-FDU.cbx) 为随附引用样式。

<details>
<summary>字体、字号与原表差异</summary>

原始 Word 文件的主标题为 16 磅加粗华文中宋，栏目标题与表头为 12 磅楷体，普通填写内容为 10.5 磅，开题次数为 11 磅，页眉、页脚与脚注说明为 9 磅。

通用示例采用 Fandol 中文字体和 TeX Gyre Termes 西文字体。字号、字重、表头居中、续页表头、灰色页眉页脚和次数下划线由文档类管理，替代字体的字形与原表存在差异。

</details>

## 检查

```sh
python3 tests/check-template.py
```

检查覆盖空白版、完整示例、长正文、表格续页、信息字段、公式与章节引用，以及不完整表格行的报错。检查需要 Python 3、`xelatex`、`biber`、`pdftotext`、`pdftohtml` 和 `pdftoppm`，编译中间文件保存在临时目录。

<details>
<summary>独立仓库维护</summary>

本项目由独立仓库 `xkwxdyy/fdu-proposal` 维护，`fduTeX` 通过 Git 子模块记录版本。首次维护子模块时应确认当前分支为 `main`；子项目独立提交、推送后，根仓库再更新版本记录。

公开仓库仅保留通用源码、模板、文献样例与文档，个人材料和本地分享压缩包继续保留在本地。

</details>

## 许可证

文档类采用项目附带的 [LaTeX Project Public License](LICENSE)，完整条款及适用范围以许可证和源文件声明为准。
