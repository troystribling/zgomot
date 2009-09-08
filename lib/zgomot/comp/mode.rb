##############################################################################################################
module Zgomot::Comp

  #####-------------------------------------------------------------------------------------------------------
  class Mode
    
    #.........................................................................................................
    @modes = [:ionian, :dorian, :phrygian, :lydian, :mixolydian, :aeolian, :locrian]
    @intervals = [2,2,1,2,2,2,1]
    @chords = {:scale => [:maj, :min, :min, :maj, :maj, :min, :dim],
               :maj   => [:maj, nil, nil, :maj, :maj, nil, nil],
               :min   => [nil, :min, :min, nil, nil, :min, nil],  
               :dim   => [nil, nil, nil, nil, nil, nil, :dim],                                                                                            
               :sus2  => [:sus2, :sus2, nil, :sus2, :sus2, :sus2, nil],
               :sus4  => [:sus4, :sus4, :sus4, nil, :sus4, :sus4, nil],
               :aug   => [nil, nil, nil, nil, nil, nil, nil]}
    
    #####-------------------------------------------------------------------------------------------------------
    class << self
    
      #.........................................................................................................
      attr_reader :modes, :intervals, :chords
    
    #### self  
    end
    
    #####-------------------------------------------------------------------------------------------------------
    attr_reader :scale, :mode
  
    #.........................................................................................................
    def initialize(mode = 1)
      @mode = case mode
                 when Symbol then self.class.modes.index(mode)+1
                 when Fixnum then mode
                 when nil then 1
                 else raise(Zgomot::Error, "#{mode.inspect} is invalid mode")
               end
      raise(Zgomot::Error, "'#{mode}' is invalid mode") if @mode.nil?
      @scale = Scale.new(self.class.intervals, @mode)        
    end
      
    #.........................................................................................................
    def chords(chord = :scale)
      shift_chords(Mode.chords[chord].clone)
    end
    
    #.........................................................................................................
    def method_missing(meth, *args, &blk )
      scale.send(meth, *args, &blk)
    end

    #.........................................................................................................
    def shift_chords(cs)
      (mode-1).times{cs.push(cs.shift)}; cs 
    end

    #.........................................................................................................
    private :shift_chords
      
  #### Mode
  end

#### Zgomot::Comp 
end
