# encoding: utf-8

module DDDocBookTools::Renderers::PDF

  class ChapterRenderer < NodeRenderer

    def process
      @pdf.start_new_page
      handle_children({
        'text'    => nil,
        'title'   => ChapterTitleRenderer,
        'section' => SectionRenderer,
        'para'    => Para,
      })
    end

  end

  class ChapterTitleRenderer < NodeRenderer

    def process
      handle_top_margin(0)

      text = @node.children.find { |e| e.text? }

      @pdf.bounding_box([0, @pdf.bounds.height - 50], width: @pdf.bounds.width) do
        @pdf.font('PT Sans', size: 18, style: :bold) do
          @pdf.text "CHAPTER #{@state.current_chapter}", align: :right
        end
        @pdf.font('PT Sans', size: 32, style: :bold) do
          @pdf.text text.text, align: :right
        end
      end
      @state.add_chapter(text.text, @pdf.page_number)

      handle_bottom_margin(180)
    end

  end

end
