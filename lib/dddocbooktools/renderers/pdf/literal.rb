# encoding: utf-8

module DDDocBookTools::Renderers::PDF

  class Literal < NodeRenderer

    def process
      { text: @node.text, font: 'Cousine', size: 10 }
    end

  end

end
