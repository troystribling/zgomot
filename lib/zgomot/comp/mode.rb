##############################################################################################################
module Zgomot::Comp

  #####-------------------------------------------------------------------------------------------------------
  class Mode
    
    #.........................................................................................................
    @modes = [:ionian, :dorian, :phrygian, :lydian, :mixolydian, :aeolian, :locrian]
    @intervals = [2,2,1,2,2,2,1]
    
    #####-------------------------------------------------------------------------------------------------------
    class << self
    
      #.........................................................................................................
      attr_reader :modes, :intervals
    
    #### self  
    end
    
    #####-------------------------------------------------------------------------------------------------------
    attr_reader :scale, :mode
  
    #.........................................................................................................
    def initialize(mode = 1)
      @mode = if mode.kind_of?(Symbol)
                self.class.modes.index(mode)
              else
                mode if mode > 0 and mode <= 7
              end
      raise(Zgomot::Error, "'#{mode}' is invalid mode") if @mode.nil?
      @scale = Scale.new(self.class.intervals, @mode)        
    end
      
    #.........................................................................................................
    def method_missing(method, *args, &blk )
      scale.send(method, *args, &blk)
    end
      
  #### Mode
  end

#### Zgomot::Comp 
end
