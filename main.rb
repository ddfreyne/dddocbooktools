# encoding: utf-8

require 'prawn'
require 'nokogiri'

require './renderers'

doc = Nokogiri::XML.parse($stdin)

Prawn::Document.generate("nanoc.pdf") do |pdf|

  pdf.font_families.update("PT Sans" => {
    normal:      "fonts/PT-Sans/PTS55F.ttf",
    italic:      "fonts/PT-Sans/PTS56F.ttf",
    bold:        "fonts/PT-Sans/PTS75F.ttf",
    bold_italic: "fonts/PT-Sans/PTS76F.ttf",
  })

  pdf.font_families.update("Gentium Basic" => {
    normal:      "fonts/GentiumBasic_1102/GenBasR.ttf",
    italic:      "fonts/GentiumBasic_1102/GenBasI.ttf",
    bold:        "fonts/GentiumBasic_1102/GenBasB.ttf",
    bold_italic: "fonts/GentiumBasic_1102/GenBasBI.ttf",
  })

  pdf.font_families.update("Cousine" => {
    normal:      "fonts/cousine/Cousine-Regular.ttf",
    italic:      "fonts/cousine/Cousine-Italic.ttf",
    bold:        "fonts/cousine/Cousine-Bold.ttf",
    bold_italic: "fonts/cousine/Cousine-BoldItalic.ttf",
  })

  pdf.font 'Gentium Basic'
  pdf.font_size 12
  pdf.default_leading 2

  state = State.new

  RootRenderer.new(doc, pdf, state).process

end
