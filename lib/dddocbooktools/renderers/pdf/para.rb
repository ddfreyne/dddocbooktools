# encoding: utf-8

module DDDocBookTools::Renderers::PDF

  class Simpara < NodeRenderer

    def process
      handle_top_margin(0)

      res = handle_children({
        'text'     => Text,
        'emphasis' => Emphasis,
        'literal'  => Literal,
        'ulink'    => Ulink,
        'xref'     => Xref,
      })

      @pdf.formatted_text(res.compact)

      handle_bottom_margin(10)
    end

  end

  class Para < NodeRenderer

    def process
      handle_top_margin(0)

      res = handle_children({
        'text'     => Text,
        'emphasis' => Emphasis,
        'literal'  => Literal,
        'ulink'    => Ulink,
        'xref'     => Xref,
      })

      @pdf.formatted_text(res.compact)

      handle_bottom_margin(10)
    end

  end

  class BoldPara < NodeRenderer

    def process
      handle_top_margin(0)

      res = handle_children({
        'text'     => Text,
        'emphasis' => Emphasis,
        'literal'  => Literal,
        'ulink'    => Ulink,
        'xref'     => Xref,
      })

      @pdf.formatted_text(res.compact.map do |e|
        e.merge({ styles: e.fetch(:styles, []) + [ :bold ] })
      end)

      handle_bottom_margin(10)
    end

  end

end
