\NeedsTeXFormat{LaTeX2e}
\RequirePackage{expl3}
\ProvidesExplClass {fdu-proposal} {2024-11-11} {v1.0}
  {Thesis template for proposal of master and doctor of Fudan University}
\RequirePackage { l3keys2e, xparse }


% 宏包报错信息
\msg_new:nnn { fdu-proposal } { l3-too-old }
  {
    Package~ "#1"~ is~ too~ old. \\\\
    Please~ update~ an~ up-to-date~ version~ of~ the~ bundles \\
    "l3kernel"~ and~ "l3packages"~ using~ your~ TeX~ package \\
    manager~ or~ from~ CTAN.
  }
% 检测 l3keys2e 的版本
\clist_map_inline:nn { l3keys2e }
  {
    \@ifpackagelater {#1} { 2020/07/17 }
      { } { \msg_error:nnn { fdu-proposal } { l3-too-old } {#1} }
  }
% 编译方式的报错信息
\msg_new:nnn { fdu-proposal } { unsupported-engine }
  {
    The~ fdu-proposal~ class~ requires~ either~ XeTeX~ or~ LuaTeX. \\\\
    "#1"~ is~ not~ supported~ at~ present.~ You~ must~ change \\
    your~ typesetting~ engine~ to~ "xelatex"~ or~ "lualatex".
  }
% 仅支持 xelatex 和 luatex 的编译方式
\sys_if_engine_xetex:F
  {
    \sys_if_engine_luatex:F
      {
        \msg_fatal:nnx { fdu-proposal } { unsupported-engine }
          { \c_sys_engine_str }
      }
  }

\cs_generate_variant:Nn \tl_map_inline:nn { xn }
\prg_generate_conditional_variant:Nnn \clist_if_in:Nn { Nx } { T, TF }

\clist_new:N \l__fpp_tmpa_clist
\clist_new:N \l__fpp_tmpb_clist
\dim_new:N \l__fpp_tmpa_dim
\dim_new:N \l__fpp_tmpb_dim
\skip_new:N \l__fpp_tmpa_skip
\skip_new:N \l__fpp_tmpb_skip
\tl_new:N \l__fpp_tmpa_tl
\tl_new:N \l__fpp_tmpb_tl
\box_new:N \l__fpp_tmpa_box
\box_new:N \l__fpp_tmpb_box

\cs_new_protected:Npn \__fpp_cover_infomation_center_underline_box:nn #1#2
  {
    \mode_leave_vertical:
    \CJKunderline*
      [
        thickness = 1pt
      ]
      {
        \hbox_to_wd:nn { #1 + 5mm } 
          { 
            \hfil 
              #2
            \hfil
          }
      }
  }
\cs_generate_variant:Nn \__fpp_cover_infomation_center_underline_box:nn  { Vn }

\cs_new:Npn \__fpp_get_max_text_width:NN #1#2
  {
    \group_begin:
      \clist_set_eq:NN \l__fpp_tmpa_clist #2
      \bool_until_do:nn { \clist_if_empty_p:N \l__fpp_tmpa_clist }
        {
          \clist_pop:NN \l__fpp_tmpa_clist \l__fpp_tmpa_tl
          \__fpp_get_text_width:NV \l__fpp_tmpa_dim \l__fpp_tmpa_tl
          \dim_gset:Nn #1 { \dim_max:nn {#1} { \l__fpp_tmpa_dim } }
        }
    \group_end:
  }
\cs_new:Npn \__fpp_get_text_width:Nn #1#2
  {
    \hbox_set:Nn \l__fpp_tmpa_box {#2}
    \dim_set:Nn #1 { \box_wd:N \l__fpp_tmpa_box }
  }
\cs_generate_variant:Nn \__fpp_get_text_width:Nn { NV }
% 用户设置命令
\NewDocumentCommand \fppsetup { m }
  { \keys_set:nn { fdu-proposal } {#1} }


% 消除 CJK 警告
\RequirePackage { filehook }
\AtEndOfPackageFile* { fontspec }
  { \msg_redirect_name:nnn { fontspec } { no-script } { none } }
\AtEndOfPackageFile* { xeCJK }
  {
    \msg_redirect_name:nnn { xeCJK } { CJKfamily-redef } { none }
    \defaultCJKfontfeatures { Script  = CJK }
  }


\LoadClass [ oneside, zihao = 5] {ctexbook}


\RequirePackage { fancyhdr }
\RequirePackage { geometry }
\RequirePackage { xeCJKfntef }
\RequirePackage { tikzpagenodes }
\RequirePackage { tabularray }
\RequirePackage { needspace }



\geometry
  {
    a4paper,
    margin = 2cm,
    footskip = 8mm,
    % showframe
  }

\fancypagestyle { plain }
  {
    \fancyhf { }
    \RenewDocumentCommand { \headrulewidth } { } { 0.4pt }
    \RenewDocumentCommand { \footrulewidth } { } { 0pt }
    \fancyfoot [ C ] {  \zihao{-5} \color{gray} \{姓名\}：\l__fpp_info_name_tl }
    \fancyfoot [ R ] {  \zihao{-5} \color{gray} \{学号\}：\l__fpp_info_student_id_tl \hspace*{3.5em}  }
    \fancyhead [ R ] { \zihao{-5} 复旦大学研究生培养手册·开题报告记录表 }
  }

\pagestyle { plain }


\ctexset
  {
    secnumdepth = 4,
    chapter =
      {
        name = {,、},
        number = \chinese{chapter},
        format = \zihao { -4 } \bfseries \heiti \raggedright,
        aftername = {},
        beforeskip = -1.6em,
        afterskip = 0em,
      },
    section =
      {
        format = \zihao { -4 } \kaishu \raggedright,
        name = {,.},
        aftername = {},
        number = \arabic{section},
        afterskip = 0.6em,
      },
  }

% 修改 parindent
\AtBeginDocument
  {
    \setlength { \parindent } { 1em }
  }

% 信息接口
\str_new:N \g__fpp_examination_method_str
\keys_define:nn { fdu-proposal / info }
  {
    year        .int_set:N   = \l__fpp_info_year_int,
    month       .int_set:N   = \l__fpp_info_month_int,
    day         .int_set:N   = \l__fpp_info_day_int,
    name      .tl_set:N    = \l__fpp_info_name_tl,
    supervisor  .tl_set:N    = \l__fpp_info_supervisor_tl,
    department  .tl_set:N    = \l__fpp_info_department_tl,
    major       .tl_set:N    = \l__fpp_info_major_tl,
    research-area    .tl_set:N    = \l__fpp_info_research_area_tl,
    student-id  .tl_set:N    = \l__fpp_info_student_id_tl,
  }

\keys_define:nn { fdu-proposal }
  {
    info .meta:nn = { fdu-proposal / info } {#1}
  }


\dim_new:N \g__fpp_box_width_extra_dim   % box 的额外宽度
\dim_new:N \g__fpp_box_height_extra_dim  % box 的下面的额外高度
\dim_set:Nn \g__fpp_box_width_extra_dim { 5pt }
\dim_set:Nn \g__fpp_box_height_extra_dim { 7pt }

\clist_new:N \g__fpp_chapter_page_clist  % 用来存 chapter 所在页面的页码，用于判定框的类型
\cs_set_eq:NN \chapter:nn \chapter
\cs_new:Npn \chapter_star:n #1
  {
    \chapter:nn * {#1}
  }

\RenewDocumentCommand{ \chapter }{ s O{#3} m }   % 注意#2 的默认值是 #3，如果为空的话目录和页眉就没有标题了
  {
    \IfBooleanTF {#1}
      { \chapter_star:n {#3} }
      { \chapter:nn [#2] {#3} }
    \clist_gput_right:Nx \g__fpp_chapter_page_clist { \thepage }
  }

% https://ask.latexstudio.net/ask/question/17502.html
\cs_new_protected:Npn \__dpp_needspace_if_newpage:nTF #1
  {
    % 可以试试删掉 \begingroup 和 \endgroup 之间的内容，看看能否正确判断第四个标题
    \par \penalty-100\begingroup
    \setlength{\dimen@}{\dimexpr#1}
    \dimen@ii\pagegoal \advance\dimen@ii-\pagetotal
    \ifdim \dimen@>\dimen@ii
      \ifdim\dimen@ii>\z@ \vfil\fi
      \penalty-\@M
    \fi\endgroup
    % 上面这些是 \Needspace 的代码，可以直接用 \Needspace{\dimexpr#1} 或 \Needspace*{\dimexpr#1} 替代
    \bool_lazy_or:nnTF
      { \dim_compare_p:nNn { \pagegoal } = { \c_max_dim} }
      { \int_compare_p:nNn { \lastpenalty } < { -9999 } } % -\@M = -10000
  }
\cs_set_eq:NN \section:nn \section

\RenewDocumentCommand{ \section }{ m }
  {
    \__dpp_needspace_if_newpage:nTF { 1.5cm }
      { }
      {
        \int_compare:nNnT { \c@section } > { 0 }
          {
            \tl_if_eq:nnF {协助导师具体指导的人员配备情况及现有条件} {#1}
              {
                \__fpp_part_end_line:
                \vspace*{-2em}
              }
          }
      }

    \section:nn {#1}
  }

\AddToHook { shipout / background }
  {
    \put (0cm,0cm)
      {
        \int_compare:nNnT { \c@page } > { 0 }  % 去掉封面的框
          {
            \clist_if_in:NxTF \g__fpp_chapter_page_clist { \int_use:N \c@page }
              {
                \__fpp_content_box_move:
              }
              {
                \__fpp_content_box_without_move:
              }
          }
      }
  }

\cs_new:Npn \__fpp_content_box_without_move:
  {
    \begin{tikzpicture}[ remember~picture, overlay ]
      \draw 
        ([shift = {(-\g__fpp_box_width_extra_dim, \g__fpp_box_height_extra_dim)}]current~page~text~area.north~west) 
        -- 
        ([shift = {(\g__fpp_box_width_extra_dim, \g__fpp_box_height_extra_dim)}]current~page~text~area.north~east)
        --
        ([shift = {(\g__fpp_box_width_extra_dim, -4pt)}]current~page~text~area.south~east)
        --
        ([shift = {(-\g__fpp_box_width_extra_dim, -4pt)}]current~page~text~area.south~west) -- cycle
        ;
    \end{tikzpicture}
  }
\cs_new:Npn \__fpp_content_box_move:
  {
    \begin{tikzpicture}[ remember~picture, overlay ]
      \draw 
        ([shift = {(-\g__fpp_box_width_extra_dim, -1.7em)}]current~page~text~area.north~west) 
        -- 
        ([shift = {(\g__fpp_box_width_extra_dim, -1.7em)}]current~page~text~area.north~east)
        --
        ([shift = {(\g__fpp_box_width_extra_dim, -\g__fpp_box_height_extra_dim)}]current~page~text~area.south~east)
        --
        ([shift = {(-\g__fpp_box_width_extra_dim, -\g__fpp_box_height_extra_dim)}]current~page~text~area.south~west) -- cycle
        ;
    \end{tikzpicture}
  }

\dim_new:N \g__dpp_part_end_line_width_dim
\dim_gset:Nn \g__dpp_part_end_line_width_dim { \textwidth + 2\g__fpp_box_width_extra_dim}

\cs_new_protected:Npn \__fpp_part_end_line:
  {
    \noindent
    \hspace*{-\g__fpp_box_width_extra_dim}
    \rule { \g__dpp_part_end_line_width_dim } { 0.4pt }
  }

\NewDocumentEnvironment { schedule } { +b }
  {
    \noindent
    \hspace*{-\g__fpp_box_width_extra_dim}
      \begin{tblr}
        {
          hlines, 
          vline{2-Y},
          width=\g__dpp_part_end_line_width_dim, 
          colspec={X[1]X[3]X[2]},
          columns = {font = \kaishu, c, m}
        }
        起讫日期 & 主要研究内容 & 预期结果 \\
        #1
      \end{tblr}
      \vspace*{-1em}
  }{}