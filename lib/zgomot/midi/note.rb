##############################################################################################################
module Zgomot::Midi

  #####-------------------------------------------------------------------------------------------------------
  class Note
    
    #.........................................................................................................
    PITCH_CLASS = {
      :C  => 0,  :Bs => 0,
      :Cs => 1,  :Db => 1,
      :D  => 2,
      :Ds => 3,  :Ed => 3,
      :E  => 4,  :Fd => 4,
      :F  => 5,  :Es => 5,
      :Fs => 6,  :Gb => 6,
      :G  => 7, 
      :Gs => 8,  :Ab => 8,
      :A  => 9,
      :As => 10, :Bb => 10,
      :B  => 11, :Cb => 11, 
      :R  => -1, 
    }

    #.........................................................................................................
    LENGTH = [1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024].select{|d| d <= Clock.resolution}

    #.........................................................................................................
    OCTAVE = (-1..9).to_a

    #####-------------------------------------------------------------------------------------------------------
    class << self

    #### self  
    end
    
    #.........................................................................................................
    attr_reader :pitch_class, :length, :octave, :midi, :velocity, :time_scale
    attr_accessor :time, :offset_time, :channel
  
    #.........................................................................................................
    def initialize(args)
      @pitch_class, @octave = case args[:pitch]
                                when Array then args[:pitch]
                                when Symbol then [args[:pitch], 4]
                                else raise(Zgomot::Error, "#{args[:pitch].inspect} is invalid pitch")
                              end
      @length, @velocity = args[:length], args[:velocity] 
      @midi = pitch_to_midi(pitch_class, octave)
      @time_scale = 1.0
      raise(Zgomot::Error, "#{octave} is invalid octave") unless OCTAVE.include?(octave)
      raise(Zgomot::Error, "#{length} is invalid duration") unless LENGTH.include?(length)
      raise(Zgomot::Error, "#{args[:pitch].inspect} is invalid") if midi.nil?
      raise(Zgomot::Error, "#{velocity} is invalid velocity") unless velocity < 128
    end

    #.........................................................................................................
    def to_s
      "[#{pitch_class.to_s},#{octave}].#{length}.#{midi}.#{velocity}"
    end

    #.........................................................................................................
    def bpm_scale!(bpm)
      @time_scale = 1.0/bpm.to_f; self
    end

    #.........................................................................................................
    # channel and dispatch interface
    #.........................................................................................................
    def play_at
      time.to_f + offset_time.to_f
    end
    
    #.........................................................................................................
    def length_to_sec
      time_scale*Clock.whole_note_sec/length
    end

    #.........................................................................................................
    def to_midi
      self
    end
      
    #.........................................................................................................
    def pitch_to_midi(pitch_class, octave)
      if PITCH_CLASS[pitch_class]
        (midi = 12*(octave+1)+PITCH_CLASS[pitch_class]) <= 127 ? midi : nil
      end
    end

    #.........................................................................................................
    private :pitch_to_midi
  
  #### Note
  end

#### Zgomot::Midi 
end
