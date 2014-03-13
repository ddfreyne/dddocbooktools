# encoding: utf-8

module DDDocBookTools::Renderers::PDF

  class BookInfo < NodeRenderer

    def process
      @pdf.bounding_box([0, @pdf.bounds.height - 200], width: @pdf.bounds.width) do
        @pdf.font('PT Sans', size: 48, style: :bold) do
          @pdf.text @node.css('title').text, align: :right
        end
        @pdf.font('PT Sans', size: 18) do
          text = [
            @node.css('author firstname').text,
            @node.css('author surname').text,
          ].join(' ')
          @pdf.text text, align: :right
        end
      end
    end

  end

end
