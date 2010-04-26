module Prawn
  class Document
    include ::Prawn::Graphics
    
    def initialize(options={}, &block)
      @page_number    = 0
      
      @internal_state = Prawn::Core::DocumentState.new(options)
      @internal_state.populate_pages_from_store(self)
      min_version(state.store.min_version) if state.store.min_version
      
      options[:size] = options.delete(:page_size)
      options[:layout] = options.delete(:page_layout)

      if options[:template]
        fresh_content_streams
        go_to_page(1)
      else
        if options[:skip_page_creation] || options[:template]
          start_new_page(options.merge(:orphan => true))
        else
          start_new_page(options)
        end
      end
    end
    
    def state
      @internal_state
    end
    
    def min_version(min)
      state.version = min if min > state.version
    end
    
    def go_to_page(k)
      self.page_number = k
      state.page = state.pages[k-1]
    end
    
    def page_count
      state.page_count
    end
    
    def compression_enabled?
      !!state.compress
    end
    
    def render
      ::Prawn::Core::Renderer.render(self)
    end

    # Renders the PDF document to file.
    #
    #   pdf.render_file "foo.pdf"
    #
    def render_file(filename)
      Kernel.const_defined?("Encoding") ? mode = "wb:ASCII-8BIT" : mode = "wb"
      File.open(filename,mode) { |f| f << render }
    end
    
    attr_accessor :page_number
    
    extendable_features = Module.new do
      def start_new_page(options = {})
        if last_page = state.page
          last_page_size    = last_page.size
          last_page_layout  = last_page.layout
          last_page_margins = last_page.margins
        end
  
        state.page = Prawn::Core::Page.new(self, 
          :size    => options[:size]   || last_page_size, 
          :layout  => options[:layout] || last_page_layout,
          :margins => last_page_margins )
  
        #use_graphic_settings
     
        unless options[:orphan]
          state.insert_page(state.page, @page_number)
          self.page_number += 1
     
          #save_graphics_state
      
          #canvas { image(@background, :at => bounds.top_left) } if @background 
          #@y = @bounding_box.absolute_top
     
          #float do
          #  state.on_page_create_action(self)
          #end
        end
      end  
    end
  
    include extendable_features
  end
end