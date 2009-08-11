##############################################################################################################
module Zgomot::Midi

  #####-------------------------------------------------------------------------------------------------------
  class Note

    #.........................................................................................................
    PITCH = {
      :C  => 0,  :Bs => 0,
      :Cs => 1,  :Db => 1,
      :D  => 2,
      :Ds => 3,  :Ed => 3,
      :E  => 4,  :Fd => 4,
      :F  => 5,  :Es => 5,
      :Fs => 6,  :Gb => 6,
      :G  => 7, 
      :Gs => 8,  :Ab => 7,
      :A  => 9,
      :As => 10, :Bb => 10,
      :B  => 11, :Cb => 11  
    }

    #.........................................................................................................
    DURATION = [1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024].select{|d| d <= Zgomot.config[:resolution].to_i}

    #.........................................................................................................
    OCTAVE = (-1..9).to_a

    #.........................................................................................................
    attr_reader :time, :pitch, :duration, :octave
  
    #.........................................................................................................
    def initialize(args)
      [:time, :pitch, :duration, :octave].each{|a| raise ArgumentError "#{a} is a required argument" unless args.include?(a)}
      @time = args[:time]
      @octave = OCTAVE.include?(args[:octave])? args[:octave] : raise ArgumentError "#{args[:octave]} is invalid octave"
      @duration = DURATION.include?(args[:duration])? args[:duration] : raise ArgumentError "#{args[:duration]} is invalid duration"
      @pitch = pitch_to_midi(args[:pitch]) || raise ArgumentError "#{args[:pitch]} is invalid"
    end

  private
  
  #.........................................................................................................
  def pitch_to_midi(pitch, octave)
    if PITCH[pitch]
      (midi = 12*(octave+1) + PITCH[pitch]) <= 127 ? midi : nil
    else
  end
  
  #### Note
  end

#### Zgomot::Midi 
end
