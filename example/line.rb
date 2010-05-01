require "#{File.dirname(__FILE__)}/example_helper"

pdf = Prawn::Document.new
pdf.line([100,100], [200,200])
pdf.stroke
pdf.start_new_page(:layout => :landscape)
pdf.line([10,100], [300,300])
pdf.stroke

# remove one of the pagebreaks
pdf.state.box_contents.delete_at(-3)

# modify the position of one of the lines. X marks the spot.
line = pdf.state.box_contents[-2]
line.point1 = [200,100]
line.point2 = [100,200]

pdf.render_file("example.pdf")