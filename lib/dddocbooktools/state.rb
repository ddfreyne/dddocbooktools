# encoding: utf-8

module DDDocBookTools

  class State

    attr_accessor :move_down
    attr_reader :chapters
    attr_reader :sections
    attr_reader :current_chapter
    attr_reader :current_figure

    def initialize
      @move_down = 0

      @current_chapter = 1
      @chapters = []

      @current_section = 1
      @sections = []

      @current_figure = 1
    end

    def add_chapter(title, page)
      @chapters << [ page, title, @current_chapter ]
      @current_chapter += 1

      @sections << [ page, nil,   @current_section ]
      @current_section += 1

      @current_figure = 1
    end

    def add_section(title, page)
      @sections << [ page, title, @current_section ]
      @current_section = 1
    end

    def add_figure
      @current_figure = 1
    end

  end

end
