# encoding: utf-8

module DDDocBookTools::Renderers::PDF

  class Text < NodeRenderer

    def process
      { text: @node.text.gsub(/\s+/, ' ') }
    end

  end

  class PreformattedText < NodeRenderer

    def process
      { text: @node.text.gsub(' ', Prawn::Text::NBSP) }
    end

  end

end
