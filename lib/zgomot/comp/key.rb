##############################################################################################################
module Zgomot::Comp

  #####-------------------------------------------------------------------------------------------------------
  class Key
     
    #.........................................................................................................
    attr_reader :mode, :length, :velocity, :clock, :time, :tonic, :progression, :chord 
    attr_accessor :offset_time, :channel
  
    #.........................................................................................................
    def initialize(args)
      @offset_time = args[:offset_time] || 0.0
      @length, @velocity, @tonic = args[:length], args[:velocity], args[:tonic]
      @chord, @channel = args[:chord], args[:channel]
      @progression = (1..7).to_a
      self.mode!(args[:mode]) if args[:mode]
    end

    #.........................................................................................................
    def pitches
      last_pitch, octave = tonic; pitch = [last_pitch]
      mode[0..-2].each_index{|i| pitch << PitchClass.next(tonic.first, sum(mode[0..i]))}
      pitch[1..-1].map do |p|
        octave += 1 if p < last_pitch; last_pitch = p.value; [last_pitch, octave]
      end.unshift(tonic)
    end

    #.........................................................................................................
    def tonic!(t)
      @notes = nil; @tonic = t; self
    end

    #.........................................................................................................
    def mode!(v)
      @notes = nil; @mode = v.kind_of?(Mode) ? v : Mode.new(v); self
    end

    #.........................................................................................................
    def velocity!(v)
      @notes = nil; @velocity = v; self
    end

    #.........................................................................................................
    def length!(v)
      @notes = nil; @length = v; self
    end

    #.........................................................................................................
    def [](*args)
      @progression = args; self
    end
    
    #.........................................................................................................
    def method_missing(method, *args, &blk)
      @notes = nil; progression.send(method, *args, &blk); self
    end

    #.........................................................................................................
    # midi interface
    def length_to_sec
      to_notes.inject(0.0){|s,n| s += Zgomot::Midi::Clock.whole_note_sec/n.length}
    end

    #.........................................................................................................
    def time=(t)
      @clock = Zgomot::Midi::Clock.new
      clock.update(t); @time = clock.current_time
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
      @notes = progression.map do |d| 
                 Zgomot::Midi::Note.new(:pitch => pitches[d-1], :length => length, :velocity => velocity,  
                                        :time => time, :offset_time => offset_time, :channel => channel)
               end
    end
  
    #.........................................................................................................
    def sum(a)
      a.inject(0) {|s,n| s+n}
    end
  
  #### Key
  end

#### Zgomot::Comp 
end
