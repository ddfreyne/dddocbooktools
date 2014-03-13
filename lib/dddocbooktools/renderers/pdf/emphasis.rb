# encoding: utf-8

module DDDocBookTools::Renderers::PDF

  class Emphasis < NodeRenderer

    def process
      { text: @node.text, styles: [ :italic ] }
    end

  end

end

