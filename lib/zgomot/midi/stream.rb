##############################################################################################################
module Zgomot::Midi

  #####-------------------------------------------------------------------------------------------------------
  class Stream

    #.........................................................................................................
    @streams = []

    #####-------------------------------------------------------------------------------------------------------
    class << self
      
      #.........................................................................................................
      attr_reader :streams

      #.........................................................................................................
      def str(name, opts={}, &blk)
        strm = new()
        opts[:infinite] = true if blk.arity > 0 
        if opts[:infinite]
        else
          strm.define_meta_class_method(:play, &blk)   
        end           
        streams << strm
      end

      #.........................................................................................................
      def play
        streams.each{|s| s.play}
      end
      
    #### self
    end
    
    #####-------------------------------------------------------------------------------------------------------
    attr_reader :channels, :clock
    
    #.........................................................................................................
    def intitialize()
    end

  #### Stream
  end

#### Zgomot::Midi 
end
