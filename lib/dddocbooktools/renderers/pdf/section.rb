# encoding: utf-8

module DDDocBookTools::Renderers::PDF

  class SectionRenderer < NodeRenderer

    def process
      handle_top_margin(20)

      @pdf.indent(indent, indent) do
        handle_children({
          'text'           => nil,
          'simpara'        => Simpara,
          'para'           => Para,
          'programlisting' => ProgramListing,
          'screen'         => Screen,
          'title'          => section_title_renderer_class,
          'note'           => Note,
          'section'        => SubsectionRenderer,
          'figure'         => Figure,
          'itemizedlist'   => ItemizedList,
          'qandaset'       => QAndASet,
        })
      end

      handle_bottom_margin(10)
    end

    def indent
      0
    end

    def section_title_renderer_class
      SectionTitleRenderer
    end

  end

  class SectionTitleRenderer < NodeRenderer

    def process
      handle_top_margin(0)

      text = @node.children.find { |e| e.text? }

      @pdf.indent(indent, indent) do
        @pdf.formatted_text [ { text: text.text, font: 'PT Sans', styles: [ :bold ], size: font_size } ]
      end
      @state.add_section(text.text, @pdf.page_number)

      handle_bottom_margin(10)
    end

    def level
      3
    end

    def indent
      0
    end

    def font_size
      20
    end

  end

  class SubsectionRenderer < SectionRenderer

    def section_title_renderer_class
      SubsectionTitleRenderer
    end

    def indent
      0
    end

  end

  class SubsectionTitleRenderer < SectionTitleRenderer

    def level
      4
    end

    def indent
      0
    end

    def font_size
      14
    end

  end

end
