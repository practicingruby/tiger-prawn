module Prawn
  module Core
    module Element
      class PageBreak
        def initialize(options={})
          @options = {}
        end
        
        def render_on(document)
          document.start_new_page!(@options)
        end
      end
    end
  end
end
        