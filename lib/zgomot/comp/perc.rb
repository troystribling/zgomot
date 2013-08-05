##############################################################################################################
module Zgomot::Comp

  #####-------------------------------------------------------------------------------------------------------
  class Perc
    
    #.........................................................................................................
    PERC_MAP = {
        :acoustic_bass_drum => [:B,1], 
        :bass_drum_1        => [:C,2],  :side_stick     => [:Cs,2], :acoustic_snare => [:D,2],
        :hand_clap          => [:Ds,2], :electric_snare => [:E,2],  :low_floor_tom  => [:F,2],
        :closed_hi_hat      => [:Fs,2], :high_floor_tom => [:G,2],  :pedal_hi_hat   => [:Gs,2],
        :low_tom            => [:A,2],  :open_hi_hat    => [:As,2], :low_mid_tom    => [:B,2],
        :high_mid_tom       => [:C,3],  :crash_cymbal_1 => [:Cs,3], :high_tom       => [:D,3], 
        :ride_cymbal_1      => [:Ds,3], :chinese_cymbal => [:E,3],  :ride_bell      => [:F,3], 
        :tambourine         => [:Fs,3], :splash_cymbal  => [:G,3],  :cowbell        => [:Gs,3], 
        :crash_cymbal_2     => [:A,3],  :vibraslap      => [:As,3], :ride_cymbal_2  => [:B,3],
        :high_bongo         => [:C,4],  :low_bongo      => [:Cs,4], :mute_hi_conga  => [:D,4], 
        :open_hi_conga      => [:Ds,4], :low_conga      => [:E,4],  :high_timbale   => [:F,4], 
        :low_timbale        => [:Fs,4], :high_agogo     => [:G,4],  :low_agogo      => [:Gs,4], 
        :cabasa             => [:A,4],  :maracas        => [:As,4], :short_whistle  => [:B,4],
        :long_whistle       => [:C,5],  :short_guiro    => [:Cs,5], :long_guiro     => [:D,5],  
        :claves             => [:Ds,5], :hi_woodblock   => [:E,5],  :low_woodblock  => [:F,5], 
        :mute_cuica         => [:Fs,5], :open_cuica     => [:G,5],  :mute_triangle  => [:Gs,5], 
        :open_triangle      => [:A,5],
        :R                  => :R,      
        }

    #####-------------------------------------------------------------------------------------------------------
    class << self

    #### self
    end
    
    #.........................................................................................................
    attr_reader :percs, :length, :velocity, :time_scale
  
    #.........................................................................................................
    def initialize(args)
      @length, @velocity, @percs = args[:length], args[:velocity], [args[:percs]].flatten
      @time_scale = 1.0
    end

    #.........................................................................................................
    def pitches
      percs.inject([]){|p,r| (m = Perc::PERC_MAP[r]).nil? ? p : p << m}
    end
    
    #.........................................................................................................
    def notes
      @notes ||= pitches.map do |p| 
                   Zgomot::Midi::Note.new(:pitch => p, :length => length, :velocity => velocity)
                 end                          
    end

    #.........................................................................................................
    # transforms
    #.........................................................................................................
    def bpm_scale!(v)
      @time_scale = 1.0/v.to_f; self
    end
    
    #.........................................................................................................
    # channel and dispatch interface
    #.........................................................................................................
    def channel=(chan)
      notes.each{|n| n.channel = chan}
    end

    #.........................................................................................................
    def offset=(time)
      notes.each{|n| n.offset = time}
    end
    
    #.........................................................................................................
    def time=(time)
      notes.each{|n| n.time = time}
    end

    #.........................................................................................................
    def length_to_sec
      time_scale*Zgomot::Midi::Clock.whole_note_sec/length
    end

    #.........................................................................................................
    def to_midi
      notes.map{|n| n.to_midi}
    end
      
  #### Scale
  end

#### Zgomot::Comp 
end
