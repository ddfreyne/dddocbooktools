# encoding: utf-8

module DDDocBookTools::Renderers::PDF

  class Screen < NodeRenderer

    def process
      handle_top_margin(0)

      res = handle_children({
        'text'     => PreformattedText,
        'emphasis' => Emphasis,
        'literal'  => Literal,
        'ulink'    => Ulink,
        'xref'     => Xref,
      })

      @pdf.indent(20, 20) do
        @pdf.font('Cousine', size: 10) do
          @pdf.formatted_text(res.compact)
        end
      end

      handle_bottom_margin(10)
    end

  end

  class ProgramListing < NodeRenderer

    def process
      handle_top_margin(0)

      res = handle_children({
        'text'     => PreformattedText,
        'emphasis' => Emphasis,
        'literal'  => Literal,
        'ulink'    => Ulink,
        'xref'     => Xref,
      })

      @pdf.indent(20, 20) do
        @pdf.font('Cousine', size: 10) do
          @pdf.formatted_text(res.compact)
        end
      end

      handle_bottom_margin(10)
    end

  end

end
