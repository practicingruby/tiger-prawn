module Prawn
  module Graphics
    def stroke
      paint(:stroke)
    end
    
    def fill
      paint(:fill)
    end
    
    def fill_and_stroke
      paint(:fill_and_stroke)
    end
    
    def paint(paint_command)
      state.box_contents << ::Prawn::Core::Element::Paint.new(paint_command)
    end
    
    def line(point1, point2)
      state.box_contents << ::Prawn::Core::Element::Line.new(point1, point2)
    end
  end
end

Prawn::Document.extensions << Prawn::Graphics