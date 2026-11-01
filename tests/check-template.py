#!/usr/bin/env python3
"""Compile the blank form, the example and pagination/input regression cases."""
from pathlib import Path
import json
import contextlib
import os
import re
import shutil
import subprocess
import tempfile
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]


def run(args, cwd=None, env=None):
    result = subprocess.run(args, cwd=cwd, env=env, text=True,
                            stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    if result.returncode:
        raise AssertionError(result.stdout[-6000:])
    return result.stdout


def compile_tex(source, folder, expected_failure=None):
    folder.mkdir()
    env = os.environ.copy()
    env['TEXINPUTS'] = str(ROOT) + os.pathsep
    env.pop('BIBINPUTS', None)
    args = ['xelatex', '-no-shell-escape', '-interaction=nonstopmode',
            '-halt-on-error', '-recorder', '-output-directory=' + str(folder), str(source)]
    if expected_failure:
        result = subprocess.run(args, cwd=ROOT, env=env, text=True,
                                stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        assert result.returncode != 0, 'Invalid input compiled successfully'
        assert compact(expected_failure) in compact(result.stdout.replace('(fdu-proposal)', '')), result.stdout[-4000:]
        return None
    run(args, cwd=ROOT, env=env)
    if (folder / (source.stem + ".bcf")).exists():
        run(["biber", "--input-directory=" + str(folder), "--output-directory=" + str(folder), source.stem], cwd=ROOT, env=env)
    for _ in range(2):
        run(args, cwd=ROOT, env=env)
    stem = source.stem
    log = (folder / (stem + '.log')).read_text()
    assert not re.search(r'(^!|Warning:|Overfull|Underfull|Missing character)', log, re.M), \
        '\n'.join(line for line in log.splitlines() if re.search(r'Warning:|Overfull|Underfull|Missing character', line))
    pdf = folder / (stem + '.pdf')
    text = run(['pdftotext', '-layout', str(pdf), '-'])
    pages = text.split('\f')[:-1]
    xmlpath = folder / 'positions'
    run(['pdftohtml', '-xml', '-hidden', '-i', str(pdf), str(xmlpath)])
    xml = ET.parse(xmlpath.with_suffix('.xml')).getroot()
    assert len(xml.findall('page')) == len(pages)
    return {'pdf': pdf, 'pages': pages, 'xml': xml}


def compact(text):
    return re.sub(r'\s+', '', text)


def check_positions(doc, blank=False):
    for i, page in enumerate(doc['xml'].findall('page')):
        texts = [(''.join(t.itertext()), t) for t in page.findall('text')]
        for value, t in texts:
            if not value.strip():
                continue
            top = float(t.attrib['top']) / 1.5
            left = float(t.attrib['left']) / 1.5
            right = left + float(t.attrib['width']) / 1.5
            bottom = top + float(t.attrib['height']) / 1.5
            assert 35 <= left < right <= 562, (i + 1, value, left, right)
            assert 50 <= top < bottom <= 806, (i + 1, value, top, bottom)
            if 2 <= i < len(doc['pages']) - 1 and not blank:
                if top >= 90 and top < 770 and '开题报告详情表' not in value:
                    assert bottom <= 765, (i + 1, value, bottom)
    assert '导师意见2' in compact(doc['pages'][1])


def gray_raster(pdf, page, folder, name, dpi=144):
    target = folder / name
    run(['pdftoppm', '-gray', '-r', str(dpi), '-f', str(page), '-l', str(page),
         '-singlefile', str(pdf), str(target)])
    data = target.with_suffix('.pgm').read_bytes()
    match = re.match(rb'P5\s+(\d+)\s+(\d+)\s+255\s', data)
    assert match, 'Unexpected raster format'
    width, height = map(int, match.groups())
    return width, height, data[match.end():]


def check_original_styles(doc, folder):
    pages = doc['xml'].findall('page')
    fonts = {f.attrib['id']: f.attrib for p in pages for f in p.findall('fontspec')}
    for page in pages:
        footer = [t for t in page.findall('text')
                  if float(t.attrib['top']) / 1.5 > 770
                  and any(k in ''.join(t.itertext()) for k in ['姓名', '学号'])]
        assert len(footer) == 2
        header = next(t for t in page.findall('text')
                      if '复旦大学研究生培养手册' in ''.join(t.itertext()))
        for t in footer + [header]:
            assert fonts[t.attrib['font']]['color'].lower() in ['#7f7f7f', '#808080']
    first = pages[0]
    title = next(t for t in first.findall('text')
                 if ''.join(t.itertext()) == '复旦大学研究生学位论文开题报告记录表')
    assert int(fonts[title.attrib['font']]['size']) == 24
    assert title.find('b') is not None, 'The original DOC title uses bold size 3 type'
    expert = next(t for t in first.findall('text') if ''.join(t.itertext()) == '专家姓名甲')
    center = (float(expert.attrib['left']) + float(expert.attrib['width']) / 2) / 1.5
    assert abs(center - 106.45) < 1, 'Expert names should be centered'
    assert int(fonts[expert.attrib['font']]['size']) == 16, 'Expert rows should use size 5'
    count = next(t for t in first.findall('text') if ''.join(t.itertext()) == '第一次')
    assert int(fonts[count.attrib['font']]['size']) == 17, 'The original DOC count uses 11 bp'
    width, height, pixels = gray_raster(doc['pdf'], 1, folder, 'style-first')
    left = float(count.attrib['left']) / 1.5
    extent = float(count.attrib['width']) / 1.5
    bottom = (float(count.attrib['top']) + float(count.attrib['height'])) / 1.5
    x0, x1 = round((left + extent / 3) * 2), round((left + 2 * extent / 3) * 2)
    assert any(sum(pixels[y * width + x] < 170 for x in range(x0, x1)) >= (x1 - x0) * .8
               for y in range(round((bottom - 1) * 2), round((bottom + 3) * 2))), \
        'The proposal count should be underlined'
    width, height, pixels = gray_raster(doc['pdf'], 3, folder, 'style-third')
    x0, x1 = round(51 * 2), round(543.5 * 2)
    gaps = []
    for caption in ['选题的理论意义、实际意义、创新点',
                    '所要解决的主要问题及研究途径与方法']:
        heading = next(t for t in pages[2].findall('text') if caption in ''.join(t.itertext()))
        top = float(heading.attrib['top']) / 1.5
        rules = [y for y in range(round((top - 20) * 2), round(top * 2))
                 if sum(pixels[y * width + x] < 170 for x in range(x0, x1)) > (x1 - x0) * .9]
        assert rules, caption
        gap = top - max(rules) / 2
        assert 2.5 <= gap <= 5.5, (caption, gap)
        gaps.append(round(gap, 2))
    first_paragraph = next(t for t in pages[2].findall('text')
                           if ''.join(t.itertext()).startswith('设'))
    assert abs(float(first_paragraph.attrib['left']) / 1.5 - 67.2) < 1
    return gaps


def check_footnote_layout(doc, folder):
    measured = []
    for page in [1, 2]:
        width, height, pixels = gray_raster(doc['pdf'], page, folder,
                                           'footnote-' + str(page), dpi=288)
        line_rows = []
        for y in range(round(758 * 4), round(762 * 4)):
            xs = [x for x in range(round(55 * 4), round(205 * 4))
                  if pixels[y * width + x] < 245]
            if len(xs) > 500:
                line_rows.append((y, min(xs), max(xs)))
        assert len(line_rows) == 1, ('Footnote rule should match the thin official rule', line_rows)
        y, left, right = line_rows[0]
        page_text = doc['xml'].findall('page')[page - 1].findall('text')
        number = next(t for t in page_text if ''.join(t.itertext()) == str(page)
                      and float(t.attrib['top']) > 1100
                      and float(t.attrib['left']) < 100)
        body = next(t for t in page_text if ''.join(t.itertext()).startswith(
                    '重新开题者' if page == 1 else '简要评述'))
        marker_gap = (float(body.attrib['left']) - float(number.attrib['left'])
                      - float(number.attrib['width'])) / 1.5
        assert 1 <= marker_gap <= 2, ('Footnote marker needs a thin space', marker_gap)
        assert abs(y / 4 - 759.5) <= .5
        assert abs((right - left + 1) / 4 - 144) <= .5
        assert abs(left / 4 - 56.7) <= .5

        def ink_bounds(x0, x1, y0, y1):
            ys = [y for y in range(round(y0 * 4), round(y1 * 4))
                  if sum(pixels[y * width + x] < 210
                         for x in range(round(x0 * 4), round(x1 * 4))) > 2]
            assert ys, (x0, x1, y0, y1)
            return min(ys) / 4, max(ys) / 4

        note_top, note_bottom = ink_bounds(61, 365, 764, 778)
        marker_top, marker_bottom = ink_bounds(56, 60.3, 763, 773)
        name_top, name_bottom = ink_bounds(272, 289, 778, 792)
        id_top, id_bottom = ink_bounds(434, 450, 778, 792)
        assert abs(note_top - 767.25) <= .5, note_top
        assert abs(marker_top - 767.5) <= .5, marker_top
        assert abs(marker_bottom - 771.25) <= .5, marker_bottom
        assert 3 <= name_top - note_bottom <= 4.3, (note_bottom, name_top)
        assert abs(name_top - id_top) <= .25, (name_top, id_top)
        measured.append({'page': page, 'rule_length_bp': (right - left + 1) / 4,
                         'marker_to_text_gap_bp': marker_gap,
                         'rule_to_note_ink_bp': note_top - y / 4,
                         'note_to_footer_ink_bp': name_top - note_bottom})
    return measured



def check_reviewed_details(doc):
    pages = doc['xml'].findall('page')
    fonts = {f.attrib['id']: f.attrib for p in pages for f in p.findall('fontspec')}
    text_of = lambda t: ''.join(t.itertext())
    headings = []
    for t in pages[0].findall('text'):
        if text_of(t).startswith(('（一）', '（二）', '（三）', '（四）')):
            assert abs(float(t.attrib['left']) / 1.5 - 44) < .7, 'Opening parentheses must remain inside the frame'
            headings.append(text_of(t))
    assert len(headings) == 4
    table_headers = []
    for p in pages[2:-1]:
        for t in p.findall('text'):
            if text_of(t) in ['起讫日期', '主要研究内容', '预期结果', '姓名', '职务或职称', '工作单位'] and 90 < float(t.attrib['top']) / 1.5 < 765:
                assert int(fonts[t.attrib['font']]['size']) == 18, 'All table headers must use small-four type'
                table_headers.append(text_of(t))
            if text_of(t) == '协助指导人员':
                assert int(fonts[t.attrib['font']]['size']) == 16, 'Filled cells must use size-five type'
    assert '起讫日期' in table_headers and '职务或职称' in table_headers
    schedule_page = next(p for p in pages[2:-1] if any(text_of(t) == '起讫日期' for t in p.findall('text')))
    assert any('研究进度及具体时间安排' in text_of(t) for t in schedule_page.findall('text')), 'A schedule caption must stay with its first table rows'
    p = pages[2]
    title = next(t for t in p.findall('text') if text_of(t) == '主要参考文献')
    top = float(title.attrib['top']) / 1.5
    bottom = top + float(title.attrib['height']) / 1.5
    earlier = [t for t in p.findall('text') if 250 < float(t.attrib['top']) / 1.5 < top]
    before = top - max((float(t.attrib['top']) + float(t.attrib['height'])) / 1.5 for t in earlier)
    item = next(t for t in p.findall('text') if 'conway' in text_of(t).lower())
    after = float(item.attrib['top']) / 1.5 - bottom
    assert 7 <= before <= 14 and 7 <= after <= 14, ('Bibliography heading spacing', before, after)
    assert abs(before - after) <= 3, ('Bibliography heading spacing should be balanced', before, after)
    return {'table_header_bp': 12, 'table_body_bp': 10.5,
            'bibliography_heading_gaps_bp': [round(before, 2), round(after, 2)],
            'subsection_headings_inside_frame': True}


def main():
    for tool in ['biber', 'xelatex', 'pdftotext', 'pdftohtml', 'pdftoppm']:
        assert shutil.which(tool), 'Required command not found: ' + tool
    keep = os.environ.get('FDU_PROPOSAL_CHECK_DIR')
    if keep:
        Path(keep).mkdir(parents=True, exist_ok=True)
    context = contextlib.nullcontext(keep) if keep else tempfile.TemporaryDirectory(prefix='fdu-proposal-check-')
    with context as temp:
        temp = Path(temp)
        blank = compile_tex(ROOT / 'templates/main.tex', temp / 'blank')
        assert len(blank['pages']) == 4
        check_positions(blank, blank=True)
        count_parts = [t for t in blank['xml'].findall('page')[0].findall('text')
                       if 130 <= float(t.attrib['left']) / 1.5 <= 175
                       and 295 <= float(t.attrib['top']) / 1.5 <= 320
                       and any(c in ''.join(t.itertext()) for c in ['第', '次'])]
        assert count_parts and all(c in ''.join(''.join(t.itertext()) for t in count_parts) for c in ['第', '次'])
        count_tops = [float(t.attrib['top']) / 1.5 for t in count_parts]
        assert max(count_tops) - min(count_tops) < .8, 'Blank proposal count should stay on one line'
        for n, title in enumerate(['选题有关的国内外研究综述', '选题的理论意义',
                                   '所要解决的主要问题', '研究进度', '协助导师',
                                   '与选题有关的研究工作积累', '课题经费预算'], 1):
            assert str(n) + '.' + title in compact(blank['pages'][2])
        example = compile_tex(ROOT / 'templates/example.tex', temp / 'example')
        check_positions(example)
        style_gaps = check_original_styles(example, temp / 'example')
        footnote_layout = check_footnote_layout(example, temp / 'example')
        reviewed_details = check_reviewed_details(example)
        assert '[1]' in example['pages'][2] and '??' not in ''.join(example['pages'])
        assert '专家姓名甲' in compact(example['pages'][0])

        stress = temp / 'stress.tex'
        paragraphs = '\n\n'.join('分页验证。' + '研究内容应在页面边界内连续排版，公式与表格需要保持清晰。' * 4 for _ in range(35))
        rows = '\n'.join(f'阶段 {n} & 内容 {n}：数值实验与理论验证 & 结果 {n} \\\\' for n in range(1, 71))
        people = '\n'.join(f'人员 {n} & 协助研究 & 示例单位 {n} \\\\' for n in range(1, 61))
        stress.write_text(r'''\documentclass[fontset=fandol]{fdu-proposal}
\errorcontextlines=99
\usepackage{amsmath}
\fppsetup{info={name={测试学生},student-id={TEST-000},
 department={较长院系名称的显示验证},major={基础数学与数值分析交叉方向},
 supervisor={测试导师},phone={000-0000},email={template_test@example.invalid},
 qualification-date={2099 年 12 月 31 日},
 proposal-date={2099 年 12 月 31 日\\下午 14:00},
 proposal-place={示例会议室},thesis-title={较长论文题目的换行与单元格边界验证：线性问题及其数值计算方法},
 experts={专家甲 & 教授 & 数学 & 示例研究单位 \\ 专家乙 & 研究员 & 计算数学 & 示例研究单位}}}
\begin{document}\basicInformation\supervisorComments
\chapter{开题报告详情表（可续页）}
\section{长正文验证}\label{sec:test}
''' + paragraphs + r'''
\section{研究进度及具体时间安排}
\begin{schedule}
''' + rows + r'''
\end{schedule}
\section{人员表续页验证}
\begin{assistants}
 姓名 & 职务或职称 & 工作单位 \\
''' + people + r'''
\end{assistants}
\section{引用与公式验证}
章节~\ref{sec:test} 与公式~\eqref{eq:test} 应具有有效编号。
\begin{equation}\label{eq:test} a^2+b^2=c^2.\end{equation}
\end{document}
''')
        long = compile_tex(stress, temp / 'stress')
        check_positions(long)
        combined = compact(''.join(long['pages']))
        assert 'template_test@example.invalid' in combined
        assert '阶段70' in combined and '人员60' in combined and '??' not in combined
        for marker, count in [('阶段', 70), ('人员', 60)]:
            for n in range(1, count + 1):
                assert len(re.findall(marker + r'\s*' + str(n) + r'(?!\d)', ''.join(long['pages']))) == 1, (marker, n)
        assert len(long['pages']) >= 8
        schedule_pages = [p for p in long['pages'] if re.search(r'阶段\s*\d+', p)]
        assert len(schedule_pages) > 1
        assert all('起讫日期' in compact(p) for p in schedule_pages)
        people_pages = [p for p in long['pages'] if re.search(r'人员\s*\d+', p)]
        assert len(people_pages) > 1
        assert all('职务或职称' in compact(p) for p in people_pages)

        bad = temp / 'bad-table.tex'
        bad.write_text(r'''\documentclass{fdu-proposal}\begin{document}
\basicInformation\supervisorComments\chapter{详情}
\begin{schedule} 日期 & 内容 \end{schedule}\end{document}''')
        compile_tex(bad, temp / 'bad-table', 'exactly 3 cells')
        bad_experts = temp / 'bad-experts.tex'
        bad_experts.write_text(r'''\documentclass{fdu-proposal}
\fppsetup{info={experts={姓名 & 职称}}}
\begin{document}\basicInformation\supervisorComments\blankDetails\end{document}''')
        compile_tex(bad_experts, temp / 'bad-experts', '4 cells per row')
        print(json.dumps({'blank_pages': len(blank['pages']), 'example_pages': len(example['pages']),
                          'stress_pages': len(long['pages']), 'repeated_table_headers': True,
                          'field_rendering_and_references': True, 'invalid_rows_rejected': True,
                          'clean_compilation_logs': True, 'restored_original_styles': True,
                          'separator_to_heading_gaps_bp': style_gaps,
                          'official_footnote_layout': footnote_layout, 'reviewed_details': reviewed_details}, ensure_ascii=False, indent=2))


if __name__ == '__main__':
    main()
