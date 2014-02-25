# encoding: utf-8

class NodeRenderer

  def initialize(node, pdf)
    @node = node
    @pdf  = pdf
  end

  def process
    raise 'abstract'
  end

  def notify_unhandled(node)
    puts "*** #{self.class.to_s}: unhandled element: #{node.name}"
  end

end

class RootRenderer < NodeRenderer

  def process
    @node.children.each do |node|
      klass = case node.name
      when 'book'
        BookRenderer
      end

      if klass
        klass.new(node, @pdf).process
      else
        notify_unhandled(node)
      end
    end
  end

end

class BookRenderer < NodeRenderer

  def process
    @node.children.each do |node|
      klass = case node.name
      when 'chapter'
        ChapterRenderer
      end

      if klass
        @pdf.repeat(:all, dynamic: true) do
          @pdf.stroke_horizontal_line(50, @pdf.bounds.width - 50, at: 20)
          at = [ @pdf.bounds.width - 100, 14 ]
          @pdf.font('PT Sans', size: 10) do
            @pdf.text_box(@pdf.page_number.to_s, at: at, size: 9, width: 50, align: :right)
          end
        end

        @pdf.bounding_box([ 50, @pdf.bounds.height - 30 ], width: @pdf.bounds.width - 100, height: @pdf.bounds.height - 70) do
          klass.new(node, @pdf).process
        end
      else
        notify_unhandled(node)
      end
    end
  end

end

class ChapterRenderer < NodeRenderer

  def process
    titles, nontitles = @node.children.partition do |e|
      e.name == 'title'
    end
    render_titles(titles)
    render_nontitles(nontitles)

    @pdf.start_new_page
  end

  def render_titles(titles)
    if titles.size != 1
      raise 'not enough titles or too many'
    end

    ChapterTitleRenderer.new(titles[0], @pdf).process
  end

  def render_nontitles(nontitles)
    nontitles.each do |node|
      klass = case node.name
      when 'section'
        SectionRenderer
      end

      if klass
        klass.new(node, @pdf).process
      else
        notify_unhandled(node)
      end
    end
  end

end

class ChapterTitleRenderer < NodeRenderer

  def process
    text = @node.children.find { |e| e.text? }

    @pdf.bounding_box([0, @pdf.bounds.height - 50], width: @pdf.bounds.width) do
      @pdf.font('PT Sans', size: 32, style: :bold) do
        @pdf.text text.text, align: :right
      end
    end
    @pdf.move_down(100)
  end

end

class SectionRenderer < NodeRenderer

  def process
    @node.children.each do |node|
      klass = case node.name
      when 'simpara'
        SimparaRenderer
      when 'programlisting'
        ProgramListingRenderer
      when 'screen'
        ScreenRenderer
      when 'title'
        section_title_renderer_class
      when 'note'
        NoteRenderer
      when 'section'
        SubsectionRenderer
      when 'figure'
        FigureRenderer
      end

      if klass
        @pdf.indent(indent, indent) do
          klass.new(node, @pdf).process
        end
      else
        notify_unhandled(node)
      end
    end

    @pdf.move_down(20)
  end

  def indent
    0
  end

  def section_title_renderer_class
    SectionTitleRenderer
  end

end

class SectionTitleRenderer < NodeRenderer

  def process
    text = @node.children.find { |e| e.text? }

    @pdf.indent(indent, indent) do
      @pdf.formatted_text [ { text: text.text, font: 'PT Sans', styles: [ :bold ], size: font_size } ]
    end
    @pdf.move_down(10)
  end

  def level
    3
  end

  def indent
    0
  end

  def font_size
    20
  end

end

class SubsectionRenderer < SectionRenderer

  def section_title_renderer_class
    SubsectionTitleRenderer
  end

  def indent
    0
  end

end

class SubsectionTitleRenderer < SectionTitleRenderer

  def level
    4
  end

  def indent
    0
  end

  def font_size
    14
  end

end

class NoteRenderer < NodeRenderer

  def process
    @node.children.each do |node|
      klass = case node.name
      when 'simpara'
        SimparaRenderer
      end

      if klass
        @pdf.indent(20) do
          @pdf.formatted_text [ { text: 'NOTE', styles: [ :bold ], font: 'PT Sans' } ]
          klass.new(node, @pdf).process
        end
      else
        notify_unhandled(node)
      end
    end
  end

end

class FigureRenderer < NodeRenderer

  def process
    title = @node.children.find             { |e| e.name == 'title' }
    titletext = title.children.find { |e| e.text? }
    mediaobject = @node.children.find       { |e| e.name == 'mediaobject' }
    imageobject = mediaobject.children.find { |e| e.name == 'imageobject' }
    imagedata   = imageobject.children.find { |e| e.name == 'imagedata' }

    # TODO implement
  end

end

class SimparaRenderer < NodeRenderer

  def process
    text = @node.children.find { |e| e.text? }

    res = @node.children.map do |node|
      if node.text?
        next { text: node.text }
      end

      klass = case node.name
      when 'emphasis'
        EmphasisRenderer
      when 'literal'
        LiteralRenderer
      when 'ulink'
        UlinkRenderer
      when 'xref'
        XrefRenderer
      end

      if klass
        klass.new(node, @pdf).process
      else
        notify_unhandled(node)
      end
    end

    @pdf.formatted_text(res)
    @pdf.move_down(10)
  end

end

class ScreenRenderer < NodeRenderer

  def process
    @pdf.indent(20, 20) do
      res = @node.children.map do |node|
        if node.text?
          next { text: node.text.gsub(' ', Prawn::Text::NBSP) }
        end

        klass = case node.name
        when 'emphasis'
          EmphasisRenderer
        when 'literal'
          LiteralRenderer
        when 'ulink'
          UlinkRenderer
        when 'xref'
          XrefRenderer
        end

        if klass
          klass.new(node, @pdf).process
        else
          notify_unhandled(node)
        end
      end

      @pdf.font('Cousine', size: 10) do
        @pdf.formatted_text(res)
      end
      @pdf.move_down(10)
    end
  end

end

class ProgramListingRenderer < NodeRenderer

  def process
    @pdf.indent(20, 20) do
      res = @node.children.map do |node|
        if node.text?
          next { text: node.text.gsub(' ', Prawn::Text::NBSP) }
        end

        klass = case node.name
        when 'emphasis'
          EmphasisRenderer
        when 'literal'
          LiteralRenderer
        when 'ulink'
          UlinkRenderer
        when 'xref'
          XrefRenderer
        end

        if klass
          klass.new(node, @pdf).process
        else
          notify_unhandled(node)
        end
      end

      @pdf.font('Cousine', size: 10) do
        @pdf.formatted_text(res)
      end
      @pdf.move_down(10)
    end
  end

end

class EmphasisRenderer < NodeRenderer

  def process
    { text: @node.text, styles: [ :bold ] }
  end

end

class LiteralRenderer < NodeRenderer

  def process
    { text: @node.text, font: 'Cousine', size: 10 }
  end

end

class UlinkRenderer < NodeRenderer

  def process
    target = @node[:url]
    text   = @node.children.find { |e| e.text? }.text

    { text: text, link: target }
  end

end

class XrefRenderer < NodeRenderer

  def process
    { text: '(missing)' }
  end

end
