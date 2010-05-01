module Prawn
  module Core
    module Element
      class Line
        def initialize(point1, point2)
          @point1 = point1
          @point2 = point2
        end
        
        attr_accessor :point1, :point2
      
        def render_on(document)
          document.move_to(*@point1)
          document.line_to(*@point2)
        end
      end
    end
  end
end