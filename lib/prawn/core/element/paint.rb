module Prawn
  module Core
    module Element
      class Paint
        def initialize(paint_command)
          @paint_command = paint_command
        end
      
        def render_on(document)
          case @paint_command
          when :stroke
            document.stroke!
          when :fill
            document.fill!
          when :fill_and_stroke
            document.fill_and_stroke!
          end
        end
      end
    end
  end
end