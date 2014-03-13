# encoding: utf-8

module DDDocBookTools::Renderers::PDF

  class Figure < NodeRenderer

    def process
      handle_top_margin(0)

      # Title
      title = @node.children.find { |e| e.name == 'title' }
      text = title.children.find { |e| e.text? }.text

      # Image
      mediaobject = @node.children.find       { |e| e.name == 'mediaobject' }
      imageobject = mediaobject.children.find { |e| e.name == 'imageobject' }
      imagedata   = imageobject.children.find { |e| e.name == 'imagedata' }
      href = imagedata[:fileref]

      @pdf.indent(30, 30) do
        @pdf.image(href, width: @pdf.bounds.width)
        @pdf.formatted_text([
          { text: 'Figure: ', styles: [ :bold ],   font: 'PT Sans' },
          { text: text,       styles: [ :italic ], font: 'Gentium Basic' }
          ])
      end

      handle_bottom_margin(10)
    end

  end

end
