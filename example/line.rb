require "#{File.dirname(__FILE__)}/example_helper"

pdf = Prawn::Document.new
pdf.move_to(100,100)
pdf.line_to(200,200)
pdf.stroke
pdf.render_file("line.pdf")