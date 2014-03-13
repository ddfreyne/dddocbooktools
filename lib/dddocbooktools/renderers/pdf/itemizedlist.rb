# encoding: utf-8

module DDDocBookTools::Renderers::PDF

  class ItemizedList < NodeRenderer

    def process
      handle_top_margin(0)

      handle_children({
        'listitem' => ItemizedListListItem,
      })

      handle_bottom_margin(10)
    end

  end

  class ItemizedListListItem < NodeRenderer

    def process
      handle_top_margin(0)

      orig = @pdf.cursor
      @pdf.bounding_box([0, @pdf.cursor], :width => 30, :height => 20) do
        @pdf.text "- "
      end
      @pdf.move_cursor_to orig

      @pdf.indent(10, 10) do
        handle_children({
          'para'    => Para,
          'simpara' => Simpara,
        })
      end

      handle_bottom_margin(0)
    end

  end

end
