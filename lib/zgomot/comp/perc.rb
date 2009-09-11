##############################################################################################################
module Zgomot::Comp

  #####-------------------------------------------------------------------------------------------------------
  class Perc
    
    #####-------------------------------------------------------------------------------------------------------
    class << self

      #.........................................................................................................
      # PERC_MAP = {
      #     acoustic bass drum => [:B,1], 
      #     bass drum 1 => [:C,2], side stick => [:Cs,2], acoustic snare => [:D,2], hand clap => [:Ds,2], 
      #     electric snare => [:E,2], low floor tom => [:F,2], closed hi_hat => [:Fs,2], high floor tom => [:G,2], 
      #     pedal hi_hat => [:Gs,2], low tom => [:A,2], open hi-hat => [:As,2], low-mid tom => [:B,2],
      #     high-mid tom => [:C,3], crash cymbal 1 => [:Cs,3], high tom => [:D,3], ride cymbal 1 => [:Ds,3], 
      #     chinese cymbal => [:E,3], ride bell => [:F,3], tambourine => [:Fs,3], splash cymbal => [:G,3], 
      #     cowbell => [:Gs,3], crash cymbal 2 => [:A,3], vibraslap => [:As,3], ride cymbal 2 => [:B,3],
      #     high bongo => [:C,4], low bongo => [:Cs,4], mute hi conga => [:D,4], open hi conga => [:Ds,4], 
      #     low conga => [:E,4], high timbale => [:F,4], low timbale => [:Fs,4], high agogo => [:G,4], 
      #     low agogo => [:Gs,4], cabasa => [:A,4], maracas => [:As,4], short whistle => [:B,4],
      #     long whistle => [:C,5], short guiro => [:Cs,5], long guiro => [:D,5], claves => [:Ds,5], 
      #     hi woodblock => [:E,5], low woodblock => [:F,5], mute cuica => [:Fs,5], open cuica => [:G,5], 
      #     mute triangle => [:Gs,5], open triangle => [:A,5],
      #     :rest => :R,      
      #   }

    #### self
    end
    
    #.........................................................................................................
    attr_reader :perc, :note, :length, :velocity, :time_scale
    attr_accessor :time, :offset_time, :channel
  
    #.........................................................................................................
    def initialize(int, shift)
      @length, @velocity, @chord = args[:length], args[:velocity], args[:chord]
      (@intervals =  Chord.chord_intervals[chord]) || raise(Zgomot::Error, "#{chord.inspect} is invalid")                      
      @time_scale = 1.0
    end

    #.........................................................................................................
    def bpm_scale!(bpm)
      @time_scale = 1.0/bpm.to_f; self
    end
    
    #.........................................................................................................
    def notes
      @notes ||= pitches.map do |p| 
                   Zgomot::Midi::Note.new(:pitch => p, :length => length, :velocity => velocity)
                 end                          
    end
  
    #.........................................................................................................
    # channel and dispatch interface
    #.........................................................................................................
    def length_to_sec
      time_scale*Zgomot::Midi::Clock.whole_note_sec*(1.0/length + (arp.to_f.eql?(0.0) ? 0.0 : intervals.length.to_f/arp.to_f))
    end

    #.........................................................................................................
    def to_midi
      notes.map{|n| n.to_midi}
    end
      
  #### Scale
  end

#### Zgomot::Comp 
end
