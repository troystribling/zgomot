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
      @mode = if mode.kind_of?(Symbol)
                self.class.modes.index(mode)+1
              else
                mode if mode > 0 and mode <= 7
              end
      raise(Zgomot::Error, "'#{mode}' is invalid mode") if @mode.nil?
      @scale = Scale.new(self.class.intervals, @mode)        
    end
      
    #.........................................................................................................
    def chords(chord = :scale)
      shift_chords(Mode.chords[chord].clone)
    end
    
    #.........................................................................................................
    def method_missing(method, *args, &blk )
      scale.send(method, *args, &blk)
    end

    #.........................................................................................................
    def shift_chords(cs)
      mode.times{cs.push(cs.shift)}  
    end

    #.........................................................................................................
    private :shift_chords
      
  #### Mode
  end

#### Zgomot::Comp 
end
