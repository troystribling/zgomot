##############################################################################################################
module Zgomot::Comp

  #####-------------------------------------------------------------------------------------------------------
  class Key
     
    #.........................................................................................................
    attr_reader :tonic, :mode, :length, :velocity, :clock, :time
    attr_accessor :offset_time, :channel
  
    #.........................................................................................................
    def initialize(args)
      @offset_time = args[:offset_time] || 0.0
      @length, @velocity, @tonic, @channel = args[:length], args[:velocity], args[:tonic], args[:channel]
      @mode = args[:mode].kind_of?(Mode) ? args[:mode] : Mode.new(args[:mode])
    end

    #.........................................................................................................
    def pitches
      last_pitch, octave = tonic
      pitch = [last_pitch]
      mode[0..-2].each_index{|i| pitch << PitchClass.next(tonic.first, sum(mode[0..i]))}
      pitch[1..-1].map do |p|
        octave += 1 if p < last_pitch 
        last_pitch = p.value; [last_pitch, octave]
      end.unshift(tonic)
    end

#     #.........................................................................................................
#     def reverse
# p to_notes      
#       to_notes.reverse 
# p to_notes      
#       self
#     end
    
    #.........................................................................................................
    def shift
      (@notes = to_notes.shift); self
    end

    #.........................................................................................................
    def pop
      (@notes = to_notes.po); self
    end

    #.........................................................................................................
    def method_missing(method, *args, &blk )
      to_notes.send(method, *args, &blk); self
    end

    #.........................................................................................................
    # channel and dispatch interface
    def length_to_sec
      notes.inject(0.0){|s,n| s += Zgomot::Midi::Clock.whole_note_sec/n.length}
    end

    #.........................................................................................................
    def time=(t)
      @clock = Zgomot::Midi::Clock.new
      clock.update(t)
      @time = clock.current_time
      to_notes.each do |n|
        n.time = clock.current_time
        clock.update(n.length_to_sec)
      end
    end
    
    #.........................................................................................................
    def channel=(c)
      to_notes.each{|n| n.channel = c}
    end
    
    #.........................................................................................................
    def to_notes
      @notes || notes
    end

    #.........................................................................................................
    def offset_time=(t)
      to_notes.each{|n| n.offset_time = t}
    end
    
  private

    #.........................................................................................................
    def notes
      @notes = pitches.map do |p| 
                 Zgomot::Midi::Note.new(:pitch => p, :length => length, :velocity => velocity,  
                                        :time => time, :offset_time => offset_time, :channel => channel)
               end
    end
  
    #.........................................................................................................
    def sum(a)
      a.inject(0) {|s,n| s+n}
    end
  
  #### Key
  end

  #####-------------------------------------------------------------------------------------------------------
  class KeyNote
    
    #.........................................................................................................
    attr_reader :pitch_class, :length, :octave, :midi, :velocity
    attr_accessor :time, :offset_time, :channel
  
    #.........................................................................................................
    def initialize(n)
      @offset_time = n[:offset_time] || 0.0
      @channel, @time = n[:channel], n[:time]
      @pitch_class, @octave = n[:pitch]
      @length, @velocity = n[:length], n[:velocity] 
    end
    
  #### Key
  end

#### Zgomot::Comp 
end
