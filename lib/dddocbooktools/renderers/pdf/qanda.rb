# encoding: utf-8

module DDDocBookTools::Renderers::PDF

  class QAndASet < NodeRenderer

    def process
      handle_top_margin(0)

      handle_children({
        'qandaentry' => QAndAEntry,
      })

      handle_bottom_margin(10)
    end

  end

  class QAndAEntry < NodeRenderer

    def process
      handle_top_margin(0)

      handle_children({
        'question' => QAndAEntryQuestion,
        'answer'   => QAndAEntryAnswer,
      })

      handle_bottom_margin(10)
    end

  end

  class QAndAEntryQuestion < NodeRenderer

    def process
      handle_top_margin(0)

      handle_children({
        'para' => BoldPara,
      })

      handle_bottom_margin(0)
    end

  end

  class QAndAEntryAnswer < NodeRenderer

    def process
      handle_top_margin(0)

      handle_children({
        'para' => Para,
      })

      handle_bottom_margin(0)
    end

  end

end
