module Prawn
  module Core
    module Graphics
      def move_to(x,y)
        state.page.puts("%.3f %.3f m" % [ x, y ])
      end

      def line_to(x,y)
        state.page.puts("%.3f %.3f l" % [ x, y ])
      end

      def curve_to(dest, bounds)
         curve_points = bounds << dest
         add_content("%.3f %.3f %.3f %.3f %.3f %.3f c" %
                       curve_points.flatten )
      end

      def rectangle!(point,width,height)
        x,y = map_to_absolute(point)
        add_content("%.3f %.3f %.3f %.3f re" % [ x, y - height, width, height ])
      end

      def stroke!
        state.page.puts("S")
      end
      
      def fill!
        state.page.puts("f")
      end
      
      def fill_and_stroke!
        state.page.puts("b")
      end
    end
  end
end