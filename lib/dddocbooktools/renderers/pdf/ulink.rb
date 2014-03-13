# encoding: utf-8

module DDDocBookTools::Renderers::PDF

  class Ulink < NodeRenderer

    def process
      target = @node[:url]
      text   = @node.children.find { |e| e.text? }.text

      { text: text, link: target }
    end

  end

end
