\NeedsTeXFormat{LaTeX2e}[2020/10/01]
\RequirePackage{expl3,l3keys2e,fix-cm}
\ProvidesExplClass{fdu-proposal}{2026-10-31}{1.1.6}
  {Fudan University thesis proposal record form}

\msg_new:nnn {fdu-proposal}{engine}
  {The~fdu-proposal~class~requires~XeLaTeX.}
\sys_if_engine_xetex:F {\msg_fatal:nn {fdu-proposal}{engine}}
\bool_new:N \l__fpp_bibliography_bool
\tl_new:N \l__fpp_fontset_tl
\keys_define:nn {fdu-proposal/options}
  {
    fontset .tl_set:N = \l__fpp_fontset_tl,
    fontset .initial:n = fandol,
    bibliography .bool_set:N = \l__fpp_bibliography_bool,
    bibliography .default:n = true,
    unknown .code:n = \PassOptionsToClass{\CurrentOption}{ctexbook},
  }
\ProcessKeysOptions{fdu-proposal/options}
\exp_args:Nx \PassOptionsToClass{fontset=\l__fpp_fontset_tl}{ctexbook}
\LoadClass[oneside,zihao=5,openany]{ctexbook}
\RequirePackage{geometry,tikz,array,longtable,needspace,enumitem,amsfonts,xeCJKfntef}
\RequirePackage[hidelinks]{hyperref}
\setmainfont{texgyretermes-regular.otf}[
  BoldFont=texgyretermes-bold.otf,ItalicFont=texgyretermes-italic.otf,
  BoldItalicFont=texgyretermes-bolditalic.otf]
\geometry{a4paper,left=56.7bp,right=57.1bp,top=90.4bp,bottom=83bp}
\pagestyle{empty}
\setlength\parindent{1em}
\setlength\parskip{0pt}
\setlength\topskip{0pt}
\IfFontExistsTF{KaiTi}
  {\newCJKfontfamily\Kaishu{KaiTi}[AutoFakeBold]}
  {\newCJKfontfamily\Kaishu{FandolKai-Regular.otf}[AutoFakeBold]}
\urlstyle{same}
\hypersetup{pdfauthor={},pdftitle={复旦大学研究生学位论文开题报告记录表}}

% 数据只保存在填写接口中，文档类不保存具体身份或活动信息。
\clist_map_inline:nn
  {name,student_id,department,major,research_area,supervisor,degree_level,
   degree_type,admission_method,qualification_date,phone,email,proposal_count,
   proposal_date,proposal_place,thesis_title,discipline,topic_source,experts}
  {\tl_new:c {l__fpp_info_#1_tl}}
\keys_define:nn {fdu-proposal/info}
  {
    name .tl_set:N = \l__fpp_info_name_tl,
    student-id .tl_set:N = \l__fpp_info_student_id_tl,
    department .tl_set:N = \l__fpp_info_department_tl,
    major .tl_set:N = \l__fpp_info_major_tl,
    research-area .tl_set:N = \l__fpp_info_research_area_tl,
    supervisor .tl_set:N = \l__fpp_info_supervisor_tl,
    degree-level .tl_set:N = \l__fpp_info_degree_level_tl,
    degree-type .tl_set:N = \l__fpp_info_degree_type_tl,
    admission-method .tl_set:N = \l__fpp_info_admission_method_tl,
    qualification-date .tl_set:N = \l__fpp_info_qualification_date_tl,
    phone .tl_set:N = \l__fpp_info_phone_tl,
    email .tl_set:N = \l__fpp_info_email_tl,
    proposal-count .tl_set:N = \l__fpp_info_proposal_count_tl,
    proposal-date .tl_set:N = \l__fpp_info_proposal_date_tl,
    proposal-place .tl_set:N = \l__fpp_info_proposal_place_tl,
    thesis-title .tl_set:N = \l__fpp_info_thesis_title_tl,
    discipline .tl_set:N = \l__fpp_info_discipline_tl,
    topic-source .tl_set:N = \l__fpp_info_topic_source_tl,
    experts .tl_set:N = \l__fpp_info_experts_tl,
    % 保留旧入口；开题时间使用 proposal-date 字段。
    year .int_set:N = \l__fpp_info_year_int,
    month .int_set:N = \l__fpp_info_month_int,
    day .int_set:N = \l__fpp_info_day_int,
  }
\keys_define:nn {fdu-proposal}{info .meta:nn = {fdu-proposal/info}{#1}}
\NewDocumentCommand\fppsetup{m}{\keys_set:nn {fdu-proposal}{#1}}

\int_new:N \g__fpp_page_kind_int
\int_new:N \g__fpp_detail_first_page_int
\bool_new:N \g__fpp_information_bool
\bool_new:N \g__fpp_blank_details_bool
\tl_new:N \g__fpp_chapter_title_tl
\seq_new:N \l__fpp_expert_rows_seq
\seq_new:N \l__fpp_expert_cells_seq
\seq_new:N \l__fpp_table_rows_seq
\msg_new:nnn {fdu-proposal}{experts}
  {The~first-page~form~accepts~at~most~10~expert~rows,~with~4~cells~per~row.}

\seq_new:N \l__fpp_map_seq
\cs_new_protected:Npn \__fpp_map_indexed:nn #1#2
  {
    \group_begin:
    \seq_set_from_clist:Nn \l__fpp_map_seq {#1}
    \seq_map_indexed_inline:Nn \l__fpp_map_seq {#2}
    \group_end:
  }
\cs_new:Npn \__fpp_kai: {\kaishu\zihao{-4}}
\cs_new:Npn \__fpp_value_font: {\kaishu\zihao{5}}
\cs_new_protected:Npn \__fpp_text:nnnnn #1#2#3#4#5
  {
    \node[anchor=north~west,inner~sep=0pt,outer~sep=0pt,
      text~width=#3bp,align=left,font={#4}] at (#1,\fp_eval:n{#2+.75}) {#5};
  }
\box_new:N \l__fpp_cell_box
\cs_new_protected:Npn \__fpp_cell:nnnnn #1#2#3#4#5
  {\__fpp_cell_align:nnnnnn{#1}{#2}{#3}{#4}{l}{#5}}
\cs_new_protected:Npn \__fpp_cell_align:nnnnnn #1#2#3#4#5#6
  {
    \node[anchor=west,inner~sep=0pt,outer~sep=0pt,font={#4}] at (#1,#2)
      {\vbox_set:Nn \l__fpp_cell_box
        {\hsize=#3bp\parindent=0pt
         \str_if_eq:nnTF{#5}{c}{\centering}{\raggedright}\noindent #6\par}
       \dim_compare:nNnTF
        {\box_ht:N\l__fpp_cell_box+\box_dp:N\l__fpp_cell_box}>{18.4bp}
        {\makebox[#3bp][#5]{\resizebox*{!}{18.4bp}{\box_use_drop:N\l__fpp_cell_box}}}
        {\box_use_drop:N\l__fpp_cell_box}};
  }
\cs_new_protected:Npn \__fpp_label:nnn #1#2#3
  {\node[inner~sep=0pt,outer~sep=0pt,font={\__fpp_kai:}] at (\fp_eval:n{#1+.5},\fp_eval:n{#2+.5}) {#3};}
\cs_new_protected:Npn \__fpp_heading:nn #1#2
  {\__fpp_text:nnnnn {56.7}{#1}{480}{\heiti\bfseries\fontsize{12bp}{14bp}\selectfont}{#2}}
\cs_new_protected:Npn \__fpp_frame:nnnn #1#2#3#4
  {\draw[line~width=1.44bp] (#1,#2) rectangle (#3,#4);}
% 页脚与脚注按共同基线定位，避免填写内容改变字框高度后发生偏移。
\cs_new_protected:Npn \__fpp_footer:nn #1#2
  {
    \node[anchor=base~west,inner~sep=0pt,outer~sep=0pt,
      text~width=155bp,align=left,
      font={\color{gray}\songti\fontsize{9bp}{11bp}\selectfont}]
      at (#1,\fp_eval:n{#2+7.4}) {\{姓名\}：\l__fpp_info_name_tl};
    \node[anchor=base~west,inner~sep=0pt,outer~sep=0pt,
      text~width=155bp,align=left,
      font={\color{gray}\songti\fontsize{9bp}{11bp}\selectfont}]
      at (\fp_eval:n{#1+162},\fp_eval:n{#2+7.4}) {\{学号\}：\l__fpp_info_student_id_tl};
  }
\cs_new_protected:Npn \__fpp_note:nn #1#2
  {
    \draw[line~width=0.1bp] (56.7,759.5)--(200.7,759.5);
    \node[anchor=base~west,inner~sep=0pt,outer~sep=0pt,
      font={\normalfont\fontsize{6bp}{7bp}\selectfont}]
      at (56.7,771.5) {#1};
    \node[anchor=base~west,inner~sep=0pt,outer~sep=0pt,
      font={\songti\fontsize{9bp}{11bp}\selectfont}]
      at (61.2,774.1) {#2};
  }
\NewDocumentCommand\fppsquare{}
  {{\setlength\fboxsep{0pt}\setlength\fboxrule{0.5bp}\raisebox{-1.2bp}{\fbox{\rule{0pt}{8.5bp}\rule{8.5bp}{0pt}}}}}
\NewDocumentCommand\checkedbox{}
  {\tikz[baseline=.7bp,x=1bp,y=1bp]{\draw[line~width=.5bp](0,0)rectangle(9,9);\draw[line~width=.7bp](1.4,4.4)--(3.7,1.8)--(7.8,7.5);}}

\cs_new_protected:Npn \__fpp_experts:
  {
    \seq_set_split:NnV \l__fpp_expert_rows_seq {\\} \l__fpp_info_experts_tl
    \seq_remove_all:Nn \l__fpp_expert_rows_seq {}
    \int_zero:N \l_tmpa_int
    \seq_map_inline:Nn \l__fpp_expert_rows_seq
      {
        \tl_if_blank:nF {##1}
          {
            \int_incr:N \l_tmpa_int
            \seq_set_split:Nnn \l__fpp_expert_cells_seq {&} {##1}
            \bool_lazy_or:nnTF
              {\int_compare_p:n {\l_tmpa_int>10}}
              {\int_compare_p:n {\seq_count:N\l__fpp_expert_cells_seq!=4}}
              {\msg_error:nn {fdu-proposal}{experts}}
              {
                \__fpp_map_indexed:nn {44,180.5,250.4,364.3}
                  {
                    \__fpp_cell_align:nnnnnn {####2}{\fp_eval:n{433.69+(\l_tmpa_int-1)*20}}
                      {\clist_item:nn {125.8,59.3,103.2,186.75}{####1}}
                      {\__fpp_value_font:}{c}
                      {\seq_item:Nn \l__fpp_expert_cells_seq {####1}}
                  }
              }
          }
      }
  }
\cs_new_protected:Npn \__fpp_information:
  {
    \__fpp_frame:nnnn {38.7}{132.57}{556.55}{743.17}
    \clist_map_inline:nn
      {153.34,173.59,193.84,214.09,234.34,254.59,296.69,319.09,339.09,359.09,
       403.69,423.69,443.69,463.69,483.69,503.69,523.69,543.69,563.69,
       583.69,603.69,623.69,643.69,663.69,683.69}
      {\draw[line~width=.48bp] (38.7,##1)--(556.55,##1);}
    \clist_map_inline:nn {275.32,380.77}
      {\draw[line~width=1.44bp] (38.7,##1)--(556.55,##1);}
    \clist_map_inline:nn {111.8,265.5,377.45}
      {\draw[line~width=.48bp](##1,153.34)--(##1,275.32);}
    \clist_map_inline:nn {130.15,175.1,245.2,327,392.9}
      {\draw[line~width=.48bp](##1,296.69)--(##1,319.09);}
    \draw[line~width=.48bp](175.1,319.09)--(175.1,380.77);
    \clist_map_inline:nn {175.1,245.2,358.8}
      {\draw[line~width=.48bp](##1,403.69)--(##1,623.69);}
    \draw[line~width=.48bp](175.1,643.69)--(175.1,683.69);
    \__fpp_map_indexed:nn
      {（一）学生基本信息,（二）开题报告基本信息,（三）参加学位论文开题报告的专家信息,（四）院系意见}
      {\__fpp_cell:nnnnn {44}{\clist_item:nn{143.2,286.35,392.6,634.45}{##1}}{505}
        {\heiti\fontsize{10.5bp}{12bp}\selectfont}{\punctstyle{plain}##2}}
    \__fpp_map_indexed:nn
      {{姓\hspace{2em}名},{院\hspace{2em}系},学位类型,{专\hspace{2em}业},{导\hspace{2em}师},联系电话}
      {\__fpp_label:nnn {74.75}{\fp_eval:n{163.45+(##1-1)*20.25}}{##2}}
    \__fpp_map_indexed:nn
      {{学\hspace{2em}号},培养层次,入学方式,研究方向,资格考试通过日期,电子邮箱}
      {\__fpp_label:nnn {320.95}{\fp_eval:n{163.45+(##1-1)*20.25}}{##2}}
    \__fpp_map_indexed:nn {name,department,degree_type,major,supervisor,phone}
      {\__fpp_cell:nnnnn {117}{\fp_eval:n{163.45+(##1-1)*20.25}}{142}
        {\__fpp_value_font:}{\tl_use:c{l__fpp_info_##2_tl}}}
    \__fpp_map_indexed:nn {student_id,degree_level,admission_method,research_area,qualification_date,email}
      {\__fpp_cell:nnnnn {382.3}{\fp_eval:n{163.45+(##1-1)*20.25}}{168.5}
        {\__fpp_value_font:}{\str_if_eq:nnTF{##2}{email}
          {\str_if_in:NnTF\l__fpp_info_email_tl{@}
            {\exp_args:NV\nolinkurl\l__fpp_info_email_tl}{\l__fpp_info_email_tl}}
          {\tl_use:c{l__fpp_info_##2_tl}}}}
    \__fpp_cell:nnnnn {44}{307.6}{85}{\__fpp_kai:}{开题报告次数}
    \__fpp_cell_align:nnnnnn {131.1}{307.6}{42.6}{\kaishu\fontsize{11bp}{13.75bp}\selectfont}{c}
      {第\tl_if_blank:VTF\l__fpp_info_proposal_count_tl{\underline{\hspace{1em}}}{\CJKunderline{\l__fpp_info_proposal_count_tl}}次}
    \__fpp_cell:nnnnn {180.5}{307.6}{64}{\__fpp_kai:}{开题时间}
    \__fpp_cell:nnnnn {250.4}{307.6}{70.6}{\__fpp_value_font:}{\l__fpp_info_proposal_date_tl}
    \__fpp_cell:nnnnn {332.6}{307.6}{60}{\__fpp_kai:}{开题地点}
    \__fpp_cell:nnnnn {397.9}{307.6}{152.8}{\__fpp_value_font:}{\l__fpp_info_proposal_place_tl}
    \__fpp_map_indexed:nn {论文题目,{所属学科、专业},选题来源}
      {\__fpp_cell:nnnnn {44}{\clist_item:nn{328.65,348.75,369.5}{##1}}{125}{\__fpp_kai:}{##2}}
    \__fpp_map_indexed:nn {thesis_title,discipline,topic_source}
      {\__fpp_cell:nnnnn {180.5}{\clist_item:nn{328.65,348.75,369.5}{##1}}{370.2}
        {\__fpp_value_font:}{\tl_use:c{l__fpp_info_##2_tl}}}
    \__fpp_map_indexed:nn {姓名,职称,{学科、专业},工作单位}
      {\__fpp_label:nnn {\clist_item:nn{106.45,209.65,301.55,457.5}{##1}}{413.5}{##2}}
    \__fpp_experts:
    \__fpp_cell:nnnnn {44}{653.45}{125}{\__fpp_kai:}{开题结果评定等级}
    \__fpp_cell:nnnnn {180.5}{653.45}{370}{\__fpp_value_font:}{通过/不通过}
    \__fpp_cell:nnnnn {44}{673.2}{125}{\__fpp_kai:}{不通过的处理意见}
    \__fpp_cell:nnnnn {180.5}{673.2}{370}{\__fpp_value_font:}
      {\fppsquare\hspace{2bp}重新开题\hspace{6bp}\fppsquare\hspace{2bp}转为硕士生培养（仅限直博生或硕博连读生）\hspace{6bp}\fppsquare\hspace{2bp}建议退学}
    \__fpp_cell:nnnnn {44}{732.7}{280}{\__fpp_kai:}{负责人签名：}
    \__fpp_cell:nnnnn {386}{732.7}{140}{\__fpp_kai:}{日期：}
  }

\cs_new_protected:Npn \__fpp_blank_details:
  {
    \clist_map_inline:nn {285.6,383.4,471.5,612,670.9,713.7}
      {\draw[line~width=.48bp](51.3,##1)--(544,##1);}
    \__fpp_map_indexed:nn
      {{选题有关的国内外研究综述（附主要参考文献）},
       {选题的理论意义、实际意义、创新点},
       {所要解决的主要问题及研究途径与方法（预期思路或技术路线）},
       {研究进度及具体时间安排},
       {协助导师具体指导的人员配备情况及现有条件},
       {与选题有关的研究工作积累、已有的研究工作成绩},{课题经费预算}}
      {\__fpp_text:nnnnn {56.7}{\clist_item:nn{114,290,388,476,616,675,718}{##1}}{481.3}
        {\__fpp_kai:\xeCJKsetup{CJKecglue={\hskip0pt}}}{##1.##2}}
    \clist_map_inline:nn {491.5,511.6,531.68,551.76,571.84,591.92}
      {\draw[line~width=.48bp](51.3,##1)--(544,##1);}
    \clist_map_inline:nn {132.2,371.45}
      {\draw[line~width=.48bp](##1,491.5)--(##1,612);}
    \__fpp_label:nnn {91.25}{501.55}{起讫日期}
    \__fpp_label:nnn {251.4}{501.55}{主要研究内容}
    \__fpp_label:nnn {457.5}{501.55}{预期结果}
  }
\cs_new_protected:Npn \__fpp_page:
  {
    \begin{tikzpicture}[remember~picture,overlay,x=1bp,y=-1bp]
    \begin{scope}[shift={(current~page.north~west)}]
      \node[anchor=north~east,inner~sep=0pt,font={\color{gray}\songti\fontsize{9bp}{11bp}\selectfont}] at (538.4,58)
        {\int_compare:nNnTF{\g__fpp_page_kind_int}={4}
          {复旦大学研究生培养手册·开题报告}{复旦大学研究生培养手册·开题报告记录表}};
      \draw[line~width=.72bp](56.7,69.7)--(538.0,69.7);
      \int_case:nn {\g__fpp_page_kind_int}
        {
          {1}{
            \node[anchor=north,inner~sep=0pt,font={\songti\bfseries\fontsize{16bp}{19bp}\selectfont}]
              at (297.5,90.3) {复旦大学研究生学位论文开题报告记录表\textsuperscript{1}};
            \__fpp_heading:nn {118}{一、基本信息}
            \bool_if:NT \g__fpp_information_bool {\__fpp_information:}
            \__fpp_note:nn {1}{重新开题者需重新填写本表，连同此前的开题报告一并归入本人学业档案。}
            \__fpp_footer:nn {266.7}{778.7}
          }
          {2}{
            \__fpp_heading:nn {88.7}{二、导师意见\textsuperscript{2}}
            \draw[line~width=.48bp](42.5,104.79)--(537.95,104.79);
            \draw[line~width=1.44bp](42.5,104.79)--(42.5,723.82)--(537.95,723.82)--(537.95,104.79);
            \__fpp_cell:nnnnn {48}{680.7}{280}{\__fpp_kai:}{导师签名：}
            \__fpp_cell:nnnnn {381.3}{680.7}{130}{\__fpp_kai:}{日期：}
            \__fpp_note:nn {2}{简要评述该学位论文开题报告的规范性、选题的创新性、研究方案的可行性。}
            \__fpp_footer:nn {266.7}{778.7}
          }
          {3}{
            \int_compare:nNnTF {\value{page}}={\g__fpp_detail_first_page_int}
              {\__fpp_heading:nn {91.3}{\g__fpp_chapter_title_tl}
               \__fpp_frame:nnnn {51.3}{109.37}{544}{768.67}}
              {\__fpp_frame:nnnn {51.3}{90.4}{544}{768.67}}
            \bool_if:NT \g__fpp_blank_details_bool {\__fpp_blank_details:}
            \__fpp_footer:nn {266.7}{778.7}
          }
          {4}{
            \__fpp_heading:nn {74.7}{四、开题报告专家评议表（可续页）}
            \__fpp_frame:nnnn {51.3}{92.92}{544}{757.42}
            \__fpp_text:nnnnn {56.7}{97.3}{481.3}{\__fpp_kai:}
              {1．对选题依据、预期思路或技术路线的科学性、可行性及创新性的评价}
            \__fpp_text:nnnnn {56.7}{390}{481.3}{\__fpp_kai:}{2．存在的主要问题和改进措施}
            \__fpp_text:nnnnn {56.7}{643.3}{481.3}{\__fpp_kai:}
              {3．专家意见：\fppsquare\,{\bfseries\Kaishu 通过}\hspace{2em}\fppsquare\,{\bfseries\Kaishu 不通过}}
            \__fpp_text:nnnnn {74.7}{702}{240}{\__fpp_kai:}{记录员签名：}
            \__fpp_text:nnnnn {338.7}{702}{190}{\__fpp_kai:}{专家组长签名：}
            \__fpp_text:nnnnn {387.3}{740.7}{140}{\__fpp_kai:}{日期：}
            \__fpp_footer:nn {284.7}{789.3}
          }
        }
    \end{scope}
    \end{tikzpicture}
  }
\AddToHook{shipout/background}{\__fpp_page:}

\AtBeginDocument
  {\setlength\parindent{1em}\int_gset:Nn\g__fpp_page_kind_int{1}\setcounter{chapter}{1}\null}
\NewDocumentCommand\basicInformation{}{\bool_gset_true:N\g__fpp_information_bool}
\NewDocumentCommand\supervisorComments{}
  {\clearpage\int_gset:Nn\g__fpp_page_kind_int{2}\setcounter{chapter}{2}\null}
\RenewDocumentCommand\chapter{s O{#3} m}
  {
    \clearpage
    \int_gset:Nn\g__fpp_page_kind_int{3}
    \bool_gset_false:N\g__fpp_blank_details_bool
    \IfBooleanTF{#1}
      {\tl_gset:Nn\g__fpp_chapter_title_tl{#3}}
      {\refstepcounter{chapter}\tl_gset:Nx\g__fpp_chapter_title_tl{\chinese{chapter}、\exp_not:n{#3}}}
    \setcounter{section}{0}
    \int_gset:Nn\g__fpp_detail_first_page_int{\value{page}}
    \vspace*{14.8bp}
  }
\NewDocumentCommand\blankDetails{}
  {\chapter{开题报告详情表（可续页）}\bool_gset_true:N\g__fpp_blank_details_bool\null}
\RenewDocumentCommand\section{s m}
  {
    \par\Needspace{95bp}
    \int_compare:nNnT{\value{section}}>{0}
      {\addvspace{6bp}\nointerlineskip\hbox_to_wd:nn{0pt}
        {\hspace*{-5.4bp}\rule{492.7bp}{.48bp}\hss}\nobreak\vskip5bp\nointerlineskip}
    \noindent
    \IfBooleanF{#1}{\refstepcounter{section}}
    \group_begin:\__fpp_kai:\xeCJKsetup{CJKecglue={\hskip0pt}}
      \IfBooleanTF{#1}{#2}{\arabic{section}.#2}
      \par
    \group_end:
    \nobreak\vskip5bp\nobreak\ignorespaces
  }

\tl_new:N \l__fpp_table_body_tl
\tl_new:N \l__fpp_table_head_tl
\msg_new:nnn {fdu-proposal}{table-columns}
  {Each~schedule~or~assistants~row~requires~exactly~3~cells.}
\cs_new_protected:Npn \__fpp_prepare_rows:n #1
  {
    \seq_set_split:Nnn \l__fpp_table_rows_seq {\\} {#1}
    \seq_set_filter:NNn \l__fpp_table_rows_seq \l__fpp_table_rows_seq
      {!\tl_if_blank_p:n {##1}}
    \seq_map_inline:Nn \l__fpp_table_rows_seq
      {
        \seq_set_split:Nnn \l__fpp_expert_cells_seq {&}{##1}
        \int_compare:nNnF {\seq_count:N\l__fpp_expert_cells_seq}={3}
          {\msg_error:nn {fdu-proposal}{table-columns}}
      }
  }
\cs_new_protected:Npn \__fpp_join_rows:
  {
    \tl_clear:N \l__fpp_table_body_tl
    \seq_map_inline:Nn \l__fpp_table_rows_seq
      {\tl_put_right:Nn \l__fpp_table_body_tl {##1\\\hline}}
  }
% 表格按行分页，续页重复表头，表格边界与详情页外框对齐。
\cs_new_protected:Npn \__fpp_longtable:nnn #1#2#3
  {
    \seq_set_split:Nnn\l__fpp_expert_cells_seq{&}{#2}
    \seq_set_map:NNn\l__fpp_expert_cells_seq\l__fpp_expert_cells_seq
      {{\__fpp_kai: ##1}}
    \tl_set:Nx\l__fpp_table_head_tl{\seq_use:Nn\l__fpp_expert_cells_seq{&}}
    \setlength\LTleft{-5.4bp}\setlength\LTright{0pt plus 1fill minus 1fill}
    \setlength\LTpre{0pt}\setlength\LTpost{2bp}\setlength\tabcolsep{5bp}
    \setlength\arrayrulewidth{.48bp}\setlength\extrarowheight{.5bp}\renewcommand\arraystretch{1.6}
    \kaishu\fontsize{10.5bp}{12bp}\selectfont
    \begin{longtable}{#1}
      \hline \l__fpp_table_head_tl\\\hline\endfirsthead
      \hline \l__fpp_table_head_tl\\\hline\endhead
      #3
    \end{longtable}
  }
\NewDocumentEnvironment{schedule}{+b}
  {
    \par\begingroup
    \__fpp_prepare_rows:n {#1}
    \__fpp_join_rows:
    \tl_set:Nn\l__fpp_table_head_tl{起讫日期 & 主要研究内容 & 预期结果}
    \exp_args:NnVV\__fpp_longtable:nnn
      {>{\centering\arraybackslash}p{70.66bp}|>{\centering\arraybackslash}p{228.77bp}|>{\centering\arraybackslash}p{162.31bp}}
      \l__fpp_table_head_tl\l__fpp_table_body_tl
    \endgroup
  }{}
\NewDocumentEnvironment{assistants}{+b}
  {
    \par\begingroup
    \__fpp_prepare_rows:n {#1}
    \seq_if_empty:NTF\l__fpp_table_rows_seq
      {\tl_set:Nn\l__fpp_table_head_tl{姓名 & 职务或职称 & 工作单位}}
      {\seq_pop_left:NN\l__fpp_table_rows_seq\l__fpp_table_head_tl}
    \__fpp_join_rows:
    \exp_args:NnVV\__fpp_longtable:nnn
      {>{\centering\arraybackslash}p{145.4bp}|>{\centering\arraybackslash}p{151bp}|>{\centering\arraybackslash}p{165.34bp}}
      \l__fpp_table_head_tl\l__fpp_table_body_tl
    \endgroup
  }{}
\AtEndDocument
  {\clearpage\int_gset:Nn\g__fpp_page_kind_int{4}\setcounter{chapter}{4}\null}
% 文献数据与引用位置由正文提供；标题、间距和条目格式由模板维护。
\bool_if:NT \l__fpp_bibliography_bool
  {
    \RequirePackage[backend=biber,bibstyle=gb7714-2015,
      citestyle=gb7714-FDU,sorting=nty,gbalign=right,gbpunctin=false]{biblatex}
    \defbibheading{bibliography}[主要参考文献]
      {\par\Needspace{50bp}\addvspace{6bp}
       \noindent\textbf{#1}\par\nobreak\vspace{4bp}\nobreak}
    \defbibenvironment{bibliography}
      {\list
         {\printtext[labelnumberwidth]{\printfield{labelprefix}\printfield{labelnumber}}}
         {\setlength\labelwidth{\labelnumberwidth}
          \setlength\labelsep{\biblabelsep}
          \setlength\leftmargin{\labelnumberwidth}
          \addtolength\leftmargin{\biblabelsep}
          \setlength\itemindent{0pt}
          \setlength\topsep{0pt}\setlength\partopsep{0pt}
          \setlength\itemsep{\bibitemsep}\setlength\parsep{\bibparsep}}
       \renewcommand*\makelabel[1]{\hss##1}}
      {\endlist}
      {\item}
    \setlength\bibitemsep{0pt}
    \setlength\bibnamesep{0pt}
    \setlength\bibinitsep{0pt}
  }
\endinput
