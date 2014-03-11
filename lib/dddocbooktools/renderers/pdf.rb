# encoding: utf-8

require 'prawn'

class DDDocBookTools::Renderers::PDF

  def initialize(doc, output_filename, config)
    @doc = doc
    @output_filename = output_filename
    @config = config
  end

  def run
    Prawn::Document.generate(@output_filename) do |pdf|
      setup_fonts(pdf)
      setup_defaults(pdf)

      state = DDDocBookTools::State.new
      RootRenderer.new(@doc, pdf, state).process
    end
  end

  private

  def setup_fonts(pdf)
    @config[:fonts].each_pair do |name, variants|
      pdf.font_families.update(name => variants)
    end
  end

  def setup_defaults(pdf)
    pdf.font            @config[:defaults][:font]
    pdf.font_size       @config[:defaults][:font_size]
    pdf.default_leading @config[:defaults][:leading]
  end

  class NodeRenderer

    def initialize(node, pdf, state)
      @node  = node
      @pdf   = pdf
      @state = state
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
          klass.new(node, @pdf, @state).process
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
            at = [ 50, 14 ]
            @pdf.font('PT Sans', size: 10) do
              current_chapter = @state.chapters.reverse_each.with_index.find { |e,i| e[0] <= @pdf.page_number }
              current_section = @state.sections.reverse_each.with_index.find { |e,i| e[0] <= @pdf.page_number }

              text = ''
              if @pdf.page_number.even?
                text << @pdf.page_number.to_s
                text << '   |   '
                text << "Chapter #{current_chapter[0][2]}: #{current_chapter[0][1]}"
                align = :left
              else
                text << "#{current_section[0][1]}"
                text << '   |   '
                text << @pdf.page_number.to_s
                align = :right
              end
              @pdf.text_box(text, at: at, size: 9, width: @pdf.bounds.width - 100, align: align)
            end
          end

          @pdf.bounding_box([ 50, @pdf.bounds.height - 30 ], width: @pdf.bounds.width - 100, height: @pdf.bounds.height - 70) do
            klass.new(node, @pdf, @state).process
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

      ChapterTitleRenderer.new(titles[0], @pdf, @state).process
    end

    def render_nontitles(nontitles)
      nontitles.each do |node|
        klass = case node.name
        when 'section'
          SectionRenderer
        end

        if klass
          klass.new(node, @pdf, @state).process
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
      @state.add_chapter(text.text, @pdf.page_number)
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
            klass.new(node, @pdf, @state).process
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
      @state.add_section(text.text, @pdf.page_number)
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
            klass.new(node, @pdf, @state).process
          end
        else
          notify_unhandled(node)
        end
      end
    end

  end

  class FigureRenderer < NodeRenderer

    def process
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
        @pdf.move_down 10
      end
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
          klass.new(node, @pdf, @state).process
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
            klass.new(node, @pdf, @state).process
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
            klass.new(node, @pdf, @state).process
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

end