# fdu-proposal

复旦大学研究生学位论文开题报告记录表的 LaTeX 模板。文档类依据原始记录表校准页面和表格，保留 `fdu-proposal` 类名及原有填写命令。

## 使用

模板需要 XeLaTeX，以及包含中文支持的 TeX 发行版，例如完整的 TeX Live 或 MacTeX。默认采用发行版自带的 Fandol 字体。原始 PDF 使用的部分字体不属于 TeX 发行版，默认字体的字形与原表存在差异；安装相应字体后可通过 `fontset` 选项选择其他 CTeX 字体方案。

在本项目目录执行：

```sh
mkdir -p build
xelatex -output-directory=build templates/main.tex
xelatex -output-directory=build templates/main.tex
xelatex -output-directory=build templates/example.tex
biber --input-directory=build --output-directory=build example
xelatex -output-directory=build templates/example.tex
xelatex -output-directory=build templates/example.tex
```

也可使用：

```sh
latexmk -xelatex -outdir=build templates/example.tex
```

编辑器应选择 XeLaTeX，并将项目目录加入 TeX 搜索路径；在线编辑环境可将所选 `.tex` 文件和 `fdu-proposal.cls` 放在同一目录。

## 模板入口

- `templates/main.tex`：四页空白表，保留原表的填写区域和固定版式，适合打印及检查表格。
- `templates/example.tex`：完整的通用填写示例，包含报告正文、公式、参考文献、进度表和人员表。身份内容均为占位内容，正文仅用于排版演示。
- `fdu-proposal.cls`：文档类的维护源码。
- `applications/`：既有个人应用材料，继续单独维护，不作为公开示例。

`\blankDetails` 输出原表中的空白详情页。填写报告正文时，应采用完整示例中的 `\chapter` 和 `\section` 结构；正文允许自然续页，不限制总页数。导师意见及专家评议区域保留供正式填写或签字。

## 填写信息

首页和所有页脚统一读取 `\fppsetup{info={...}}`。未设置的字段保持空白，文档类不保存具体身份、联系方式或活动信息。

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

专家名单按以下方式填写，每行依次为姓名、职称、学科或专业、工作单位。首页保留原表的专家填写行，名单最多接受十行；每行必须填写四列，缺项使用空单元格保留。末行的 `\\` 可以省略。

```tex
\fppsetup{info={
  experts = {
    专家姓名甲 & 职称 & 学科或专业 & 工作单位 \\
    专家姓名乙 & 职称 & 学科或专业 & 工作单位
  },
}}
```

## 字体与字号

原始 Word 文件的主标题为 16 磅加粗华文中宋，栏目标题与表头为 12 磅楷体，普通填写内容为 10.5 磅，开题次数为 11 磅，页眉、页脚与脚注说明为 9 磅。简易包使用 Fandol 中文字体及 TeX Gyre Termes 西文字体作为随 TeX 发行版提供的替代字体，原字体的字形与替代字体存在差异。表头居中且大于内容字号，续页重复相同的表头格式。已确认的灰色页眉页脚和次数下划线继续保留。

## 正文与表格

报告详情保留原表的栏目名称和顺序。标题与后续内容共同参与分页，续页继续显示外框和姓名、学号。

`schedule` 环境固定使用“起讫日期、主要研究内容、预期结果”列；每行使用 `&` 分隔，使用 `\\` 结束。表格按行续页，续页重复表头。表格可以包含空单元格，但不能缺少列分隔符。

```tex
\begin{schedule}
  起止时间 & 研究内容 & 预期结果 \\
  起止时间 & 研究内容 & 预期结果
\end{schedule}
```

`assistants` 环境同样使用三列，其首行作为表头，并在续页重复。完整示例展示了填写方式。单行内容应控制在一页以内。

参考文献使用此前示例的 `biblatex + Biber` 方式。类选项 `bibliography` 启用统一样式；`references.bib` 保存文献数据，正文使用 `\parencite{文献键}` 或 `\cite{文献键}` 引用，并通过 `\printbibliography` 输出文献表。标题、间距与编号由模板管理。编译顺序为 XeLaTeX、Biber、XeLaTeX、XeLaTeX；`latexmk -xelatex` 可自动完成编译。`gb7714-FDU.cbx` 为随附的引用样式。

## 检查

```sh
python3 tests/check-template.py
```

检查覆盖四页空白版、完整示例、长正文、表格续页、信息字段、公式与章节引用，以及不完整表格行的报错。检查需要本机提供 `xelatex`、`biber`、`pdftotext`、`pdftohtml` 和 `pdftoppm`，编译中间文件保存在临时目录。

文档类采用项目附带的 LaTeX Project Public License，完整条款见 `LICENSE`。正式提交前应核对院系当前使用的表格要求。

完整示例采用泛函分析与算子理论方向，题为“紧自伴算子的谱逼近与扰动估计”。`build/example.pdf` 提供预览；`build/完整示例/` 包含可独立编译的源码、文献库、样式、说明及 PDF。

## 独立仓库维护

本目录由独立仓库 [`xkwxdyy/fdu-proposal`](https://github.com/xkwxdyy/fdu-proposal) 维护。
在本目录执行 `git commit` 和 `git push`，操作对象均为本项目。
`fduTeX` 仅通过 Git 子模块记录本项目的版本，不直接维护本项目源码。

首次在总项目中维护子模块时，先确认当前分支为 `main`；首次递归检出可能处于分离的提交状态。
先推送本项目，再按需更新 `fduTeX` 记录的子模块版本。
个人材料、活动资产和编译产物继续保留在本地，不因迁移而删除。

公开仓库不纳入 `applications/`、个人参考材料或本地分享压缩包。
