# encoding: utf-8

# prawn/core/page.rb : Implements low-level representation of a PDF page
#
# Copyright February 2010, Gregory Brown.  All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
#
module Prawn
  module Core
    class Page #:nodoc:
      attr_accessor :document, :content, :dictionary, :margins

      def initialize(document, options={})
        @document = document
        @margins  = options[:margins] || { :left    => 36,
                                           :right   => 36,
                                           :top     => 36,
                                           :bottom  => 36  }

        if options[:object_id]
          init_from_object(options)
        else
          init_new_page(options)
        end
      end

      def layout
        return @layout if @layout

        mb = dictionary.data[:MediaBox]
        if mb[3] > mb[2]
          :portrait
        else
          :landscape
        end
      end

      def size
        @size || dimensions[2,2]
      end

      def in_stamp_stream?
        !!@stamp_stream
      end

      def stamp_stream(dictionary)
        @stamp_stream     = ""
        @stamp_dictionary = dictionary

        document.send(:update_colors)
        yield if block_given?
        document.send(:update_colors)

        @stamp_dictionary.data[:Length] = @stamp_stream.length + 1
        @stamp_dictionary << @stamp_stream

        @stamp_stream      = nil
        @stamp_dictionary  = nil
      end

      def content
        @stamp_stream || document.state.store[@content]
      end
      
      def puts(str)
        self << str << "\n"
      end
      
      def <<(str)
        content << str
      end

      # As per the PDF spec, each page can have multiple content streams. This will
      # add a fresh, empty content stream this the page, mainly for use in loading
      # template files.
      #
      def new_content_stream
        return if in_stamp_stream?

        unless dictionary.data[:Contents].is_a?(Array)
          dictionary.data[:Contents] = [content]
        end
        @content    = document.ref(:Length => 0)
        dictionary.data[:Contents] << document.state.store[@content]
      end

      def dictionary
        @stamp_dictionary || document.state.store[@dictionary]
      end

      def resources
        if dictionary.data[:Resources]
          document.deref(dictionary.data[:Resources])
        else
          dictionary.data[:Resources] = {}
        end
      end

      def fonts
        if resources[:Font]
          document.deref(resources[:Font])
        else
          resources[:Font] = {}
        end
      end

      def xobjects
        if resources[:XObject]
          document.deref(resources[:XObject])
        else
          resources[:XObject] = {}
        end
      end

      def ext_gstates
        if resources[:ExtGState]
          document.deref(resources[:ExtGState])
        else
          resources[:ExtGState] = {}
        end
      end

      def finalize
        if dictionary.data[:Contents].is_a?(Array)
          dictionary.data[:Contents].each do |stream|
            stream.compress_stream if document.compression_enabled?
            stream.data[:Length] = stream.stream.size
          end
        else
          content.compress_stream if document.compression_enabled?
          content.data[:Length] = content.stream.size
        end
      end

      def imported_page?
        @imported_page
      end

      def dimensions
        return dictionary.data[:MediaBox] if imported_page?

        coords = ::Prawn::Core::Page::SIZES[size] || size
        [0,0] + case(layout)
        when :portrait
          coords
        when :landscape
          coords.reverse
        else
          raise Prawn::Errors::InvalidPageLayout,
            "Layout must be either :portrait or :landscape"
        end
      end

      private

      def init_from_object(options)
        @dictionary = options[:object_id].to_i
        @content    = dictionary.data[:Contents].identifier

        @stamp_stream      = nil
        @stamp_dictionary  = nil
        @imported_page     = true
      end

      def init_new_page(options)
        @size     = options[:size]    ||  "LETTER" 
        @layout   = options[:layout]  || :portrait         
        
        @content    = document.state.store.ref(:Length      => 0).identifier
        @dictionary = document.state.store.ref(:Type        => :Page,
                                               :Parent      => document.state.store.pages,
                                               :MediaBox    => dimensions,
                                               :Contents    => content).identifier

        resources[:ProcSet] = [:PDF, :Text, :ImageB, :ImageC, :ImageI]

        @stamp_stream      = nil
        @stamp_dictionary  = nil
      end
      
      SIZES = { "4A0" => [4767.87, 6740.79],
                "2A0" => [3370.39, 4767.87],
                 "A0" => [2383.94, 3370.39],
                 "A1" => [1683.78, 2383.94],
                 "A2" => [1190.55, 1683.78],
                 "A3" => [841.89, 1190.55],
                 "A4" => [595.28, 841.89],
                 "A5" => [419.53, 595.28],
                 "A6" => [297.64, 419.53],
                 "A7" => [209.76, 297.64],
                 "A8" => [147.40, 209.76],
                 "A9" => [104.88, 147.40],
                "A10" => [73.70, 104.88],
                 "B0" => [2834.65, 4008.19],
                 "B1" => [2004.09, 2834.65],
                 "B2" => [1417.32, 2004.09],
                 "B3" => [1000.63, 1417.32],
                 "B4" => [708.66, 1000.63],
                 "B5" => [498.90, 708.66],
                 "B6" => [354.33, 498.90],
                 "B7" => [249.45, 354.33],
                 "B8" => [175.75, 249.45],
                 "B9" => [124.72, 175.75],
                "B10" => [87.87, 124.72],
                 "C0" => [2599.37, 3676.54],
                 "C1" => [1836.85, 2599.37],
                 "C2" => [1298.27, 1836.85],
                 "C3" => [918.43, 1298.27],
                 "C4" => [649.13, 918.43],
                 "C5" => [459.21, 649.13],
                 "C6" => [323.15, 459.21],
                 "C7" => [229.61, 323.15],
                 "C8" => [161.57, 229.61],
                 "C9" => [113.39, 161.57],
                "C10" => [79.37, 113.39],
                "RA0" => [2437.80, 3458.27],
                "RA1" => [1729.13, 2437.80],
                "RA2" => [1218.90, 1729.13],
                "RA3" => [864.57, 1218.90],
                "RA4" => [609.45, 864.57],
               "SRA0" => [2551.18, 3628.35],
               "SRA1" => [1814.17, 2551.18],
               "SRA2" => [1275.59, 1814.17],
               "SRA3" => [907.09, 1275.59],
               "SRA4" => [637.80, 907.09],
          "EXECUTIVE" => [521.86, 756.00],
              "FOLIO" => [612.00, 936.00],
              "LEGAL" => [612.00, 1008.00],
             "LETTER" => [612.00, 792.00],
            "TABLOID" => [792.00, 1224.00] }

    end
  end
end