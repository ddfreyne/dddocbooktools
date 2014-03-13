# encoding: utf-8

require 'prawn'

module DDDocBookTools::Renderers::PDF

  class Runner

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

    def handle_top_margin(x)
      @pdf.move_down([ x, @state.move_down ].max)
      @state.move_down = 0
    end

    def handle_bottom_margin(x)
      @state.move_down = [ @state.move_down, x].max
    end

    def temp_doc
      @tmp_doc ||= begin
        tmp = ::Prawn::Document.new

        tmp.font_families.update("PT Sans" => {
          normal:      "fonts/PT-Sans/PTS55F.ttf",
          italic:      "fonts/PT-Sans/PTS56F.ttf",
          bold:        "fonts/PT-Sans/PTS75F.ttf",
          bold_italic: "fonts/PT-Sans/PTS76F.ttf",
        })
        tmp.font_families.update("Gentium Basic" => {
          normal:      "fonts/GentiumBasic_1102/GenBasR.ttf",
          italic:      "fonts/GentiumBasic_1102/GenBasI.ttf",
          bold:        "fonts/GentiumBasic_1102/GenBasB.ttf",
          bold_italic: "fonts/GentiumBasic_1102/GenBasBI.ttf",
        })
        tmp.font_families.update("Cousine" => {
          normal:      "fonts/cousine/Cousine-Regular.ttf",
          italic:      "fonts/cousine/Cousine-Italic.ttf",
          bold:        "fonts/cousine/Cousine-Bold.ttf",
          bold_italic: "fonts/cousine/Cousine-BoldItalic.ttf",
        })

        tmp.font 'Gentium Basic'
        tmp.font_size 12
        tmp.default_leading 2

        tmp
      end
    end

    def estimate_height
      @pdf.bounds.absolute_top

      tmp = temp_doc
      tmp.start_new_page

      before, after = 0
      tmp.bounding_box([0, @pdf.bounds.absolute_top], width: @pdf.bounds.width, height: @pdf.bounds.height) do
        before = tmp.cursor
        yield tmp
        after = tmp.cursor
      end
      - (after - before)
    end

    def notify_unhandled(node)
      puts "*** #{self.class.to_s}: unhandled element: #{node.name}"
    end

    def handle_children(map)
      @node.children.map do |node|
        if map.has_key?(node.name)
          klass = map[node.name]
          next if klass.nil?
          klass.new(node, @pdf, @state).process
        else
          notify_unhandled(node)
          nil
        end
      end
    end

  end

  class RootRenderer < NodeRenderer

    def process
      handle_children({ 'book' => Book })
    end

  end

end

require_relative './pdf/book.rb'
require_relative './pdf/book_info.rb'
require_relative './pdf/chapter.rb'
require_relative './pdf/emphasis.rb'
require_relative './pdf/figure.rb'
require_relative './pdf/itemizedlist.rb'
require_relative './pdf/literal.rb'
require_relative './pdf/note.rb'
require_relative './pdf/para.rb'
require_relative './pdf/pre.rb'
require_relative './pdf/qanda.rb'
require_relative './pdf/section.rb'
require_relative './pdf/text.rb'
require_relative './pdf/ulink.rb'
require_relative './pdf/xref.rb'
