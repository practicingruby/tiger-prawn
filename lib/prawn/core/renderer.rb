require "stringio"

module Prawn
  module Core
    class Renderer
      def self.render(document)
        new(document).render
      end   
      
      def initialize(document)
        @document    = document
        @state       = document.state
        @xref_offset = nil
        @output      = StringIO.new
      end
      
      attr_reader :document, :state, :output
      attr_accessor :xref_offset
      
      def render
        state.box_contents.each do |e|
          e.render_on(document)
        end
        
        finalize_all_page_contents

        render_header
        render_body
        render_xref
        render_trailer
        
        str = output.string
        str.force_encoding("ASCII-8BIT") if str.respond_to?(:force_encoding)
        return str
      end
      
      def render_header
        state.before_render_actions(self)

        # pdf version
        output << "%PDF-#{state.version}\n"

        # 4 binary chars, as recommended by the spec
        output << "%\xFF\xFF\xFF\xFF\n"
      end

      # Write out the PDF Body, as per spec 3.4.2
      #
      def render_body
        state.render_body(output)
      end

      # Write out the PDF Cross Reference Table, as per spec 3.4.3
      #
      def render_xref
        self.xref_offset = output.size
        
        output << "xref\n"
        output << "0 #{state.store.size + 1}\n"
        output << "0000000000 65535 f \n"
        state.store.each do |ref|
          output.printf("%010d", ref.offset)
          output << " 00000 n \n"
        end
        
        return xref_offset
      end

      # Write out the PDF Trailer, as per spec 3.4.4
      #
      def render_trailer
        trailer_hash = {:Size => state.store.size + 1, 
                        :Root => state.store.root,
                        :Info => state.store.info}
        trailer_hash.merge!(state.trailer) if state.trailer

        output << "trailer\n"
        output << Prawn::Core.to_pdf(trailer_hash) << "\n"
        output << "startxref\n" 
        output << xref_offset << "\n"
        output << "%%EOF" << "\n"
      end
      
      def finalize_all_page_contents
        (1..document.page_count).each do |i|
          document.go_to_page i
          state.page.finalize
        end
      end  
    end
  end
end