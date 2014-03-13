# encoding: utf-8

module DDDocBookTools::Renderers::PDF

  class Note < NodeRenderer

    def process
      handle_top_margin(0)

      @pdf.indent(20) do
        @pdf.formatted_text [ { text: 'NOTE', styles: [ :bold ], font: 'PT Sans' } ]
        handle_children({
          'simpara' => Simpara,
          'para'    => Para,
        })
      end

      handle_top_margin(10)
    end

  end

end
