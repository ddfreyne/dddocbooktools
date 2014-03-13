# encoding: utf-8

require 'nokogiri'

require_relative './lib/dddocbooktools'

root = File.dirname(__FILE__)
config = {
  defaults: {
    font: 'Gentium Basic',
    font_size: 12,
    leading: 2,
  },
  fonts: {
    "PT Sans" => {
      normal:      "#{root}/data/fonts/PT-Sans/PTS55F.ttf",
      italic:      "#{root}/data/fonts/PT-Sans/PTS56F.ttf",
      bold:        "#{root}/data/fonts/PT-Sans/PTS75F.ttf",
      bold_italic: "#{root}/data/fonts/PT-Sans/PTS76F.ttf",
    },
    "Gentium Basic" => {
      normal:      "#{root}/data/fonts/GentiumBasic_1102/GenBasR.ttf",
      italic:      "#{root}/data/fonts/GentiumBasic_1102/GenBasI.ttf",
      bold:        "#{root}/data/fonts/GentiumBasic_1102/GenBasB.ttf",
      bold_italic: "#{root}/data/fonts/GentiumBasic_1102/GenBasBI.ttf",
    },
    "Cousine" => {
      normal:      "#{root}/data/fonts/cousine/Cousine-Regular.ttf",
      italic:      "#{root}/data/fonts/cousine/Cousine-Italic.ttf",
      bold:        "#{root}/data/fonts/cousine/Cousine-Bold.ttf",
      bold_italic: "#{root}/data/fonts/cousine/Cousine-BoldItalic.ttf",
    },
  }
}

doc = Nokogiri::XML.parse($stdin, nil, 'utf-8', Nokogiri::XML::ParseOptions::DEFAULT_XML | Nokogiri::XML::ParseOptions::XINCLUDE)
pdf_renderer = DDDocBookTools::Renderers::PDF.new(doc, "nanoc.pdf", config)
pdf_renderer.run
