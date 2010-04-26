module Prawn
  module Graphics 
    def move_to(x,y)
      state.page.puts("%.3f %.3f m" % [ x, y ])
    end
    
    def line_to(x,y)
      state.page.puts("%.3f %.3f l" % [ x, y ])
    end
    
    def stroke
      state.page.puts("S")
    end
  end
end