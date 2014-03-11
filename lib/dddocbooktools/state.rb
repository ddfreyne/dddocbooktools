# encoding: utf-8

module DDDocBookTools

  class State

    attr_reader :chapters
    attr_reader :sections

    def initialize
      @current_chapter = 1
      @chapters = []

      @current_section = 1
      @sections = []
    end

    def add_chapter(title, page)
      @chapters << [ page, title, @current_chapter ]
      @current_chapter += 1

      @sections << [ page, nil,   @current_section ]
      @current_section += 1
    end

    def add_section(title, page)
      @sections << [ page, title, @current_section ]
      @current_section = 1
    end

  end

end
