require "#{File.dirname(__FILE__)}/example_helper"

pdf = Prawn::Document.new
pdf.line([100,100], [200,200])
pdf.stroke
pdf.start_new_page(:layout => :landscape)
pdf.line([10,100], [300,300])
pdf.stroke

# Gets rid of the pagebreak we added.
pdf.state.box_contents.delete_at(-3)

pdf.render_file("line.pdf")