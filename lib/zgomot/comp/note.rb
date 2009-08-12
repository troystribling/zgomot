##############################################################################################################
module Zgomot::Comp

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
    CIRCLE_OF_FIFTHS_MAJOR = [:C, :G, :D, :A, :E, :B, :Fs, :Db, :Ab, :Eb, :Bb, :F]
    CIRCLE_OF_FIFTHS_MINOR = [:A, :E, :B, :Fs, :Cs, :Gs, :Ds, :Bb, :F, :C, :G, :D]

    #.........................................................................................................
    DURATION = [1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024].select{|d| d <= Clock.resolution}

    #.........................................................................................................
    OCTAVE = (-1..9).to_a

    #####-------------------------------------------------------------------------------------------------------
    class << self

      #.........................................................................................................
      def next_pitch_class(pc, interval)
        start_pos = PITCH_CLASS[pc]
        PITCH_CLASS.inject([]){|r,(c,p)|  p.eql?(start_pos+interval) ? r << c : r}.first if start_pos
      end
      
    end
    
    #####-------------------------------------------------------------------------------------------------------
    attr_reader :time, :pitch_class, :duration, :octave, :midi, :velocity
  
    #.........................................................................................................
    def initialize(args)
      [:time, :pitch].each{|a| raise ArgumentError "#{a} is a required argument" unless args.include?(a)}
      @time = args[:time]
      @pitch_class, @octave = (args[:pitch].kind_of?(Array) ? args[:pitch] : [args[:pitch], 5])
      @duration = args[:duration] || 4
      @velocity = args[:velocity] || 100 
      @midi = to_midi(pitch_class, octave)
      raise ArgumentError "#{octave} is invalid octave" unless OCTAVE.include?(octave)
      raise ArgumentError "#{duration} is invalid duration" unless DURATION.include?(duration)
      raise ArgumentError "#{args[:pitch].inspect} is invalid" if midi.nil?
      raise ArgumentError "#{velocity} is invalid velocity" unless velocity < 128
    end

  private
  
  #.........................................................................................................
  def to_midi(pitch_class, octave)
    if PITCH_CLASS[pitch_class]
      (midi = 12*(octave+1)+PITCH_CLASS[pitch_class]) <= 127 ? midi : nil
    else
  end

  #.........................................................................................................
  def sec
    Clock.whole_note_sec/duration
  end
  
  #### Note
  end

#### Zgomot::Midi 
end
