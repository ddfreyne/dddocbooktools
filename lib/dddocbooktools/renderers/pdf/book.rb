# encoding: utf-8

module DDDocBookTools::Renderers::PDF

  class Book < NodeRenderer

    def process
      @pdf.repeat(:all, dynamic: true) do
        @pdf.stroke_horizontal_line(50, @pdf.bounds.width - 50, at: 20)
        at = [ 50, 14 ]
        @pdf.font('PT Sans', size: 10) do
          current_chapter = @state.chapters.reverse_each.with_index.find { |e,i| e ? e[0] <= @pdf.page_number : false }
          current_section = @state.sections.reverse_each.with_index.find { |e,i| e ? e[0] <= @pdf.page_number : false }

          next if current_chapter.nil? || current_section.nil?

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
        handle_children({
          'text'     => nil,
          'bookinfo' => BookInfo,
          'chapter'  => ChapterRenderer,
          'section'  => SectionRenderer,
        })
      end
    end

  end

end
