##############################################################################################################
module Zgomot::Comp

  #####-------------------------------------------------------------------------------------------------------
  class Progression
     
    #.........................................................................................................
    attr_reader :mode, :length, :velocity, :clock, :time, :tonic, :items, :item
    attr_accessor :offset_time, :channel
  
    #.........................................................................................................
    def initialize(args)
      @channel, @offset_time = (args[:offset_time] || 0.0), args[:channel]
      @length, @velocity, @tonic, @item = args[:length], args[:velocity], args[:tonic], args[:item]
      @items = (1..7).to_a
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
      @items = args; self
    end
    
    #.........................................................................................................
    def new_respond_to?(meth, include_private=false)
      old_respond_to?(meth, include_private=false) || (not notes.select{|n| n.respond_to?(meth, include_private=false)}.empty?)    
    end
    alias_method :old_respond_to?, :respond_to?
    alias_method :respond_to?, :new_respond_to?
      
    #.........................................................................................................
    def method_missing(meth, *args, &blk)
      @notes = nil
      if not notes.select{|n| n.respond_to?(meth, include_provate=false)}.empty?
        @notes = notes.map do |n|
                   n.respond_to?(meth, include_provate=false) ? n.send(meth, *args, &blk) : n
                 end
      else
        items.send(meth, *args, &blk)
      end
      self
    end

    #.........................................................................................................
    # midi interface
    def length_to_sec
      notes.inject(0.0){|s,n| s += Zgomot::Midi::Clock.whole_note_sec/n.length}
    end

    #.........................................................................................................
    def time=(t)
      @clock = Zgomot::Midi::Clock.new
      clock.update(t); @time = clock.current_time
      notes.each do |n|
        n.time = clock.current_time
        clock.update(n.length_to_sec)
      end
    end
    
    #.........................................................................................................
    def channel=(c)
      notes.each{|n| n.channel = c}
    end
    
    #.........................................................................................................
    def to_midi
      notes.map{|n| n.to_midi}
    end

    #.........................................................................................................
    def offset_time=(t)
      notes.each{|n| n.offset_time = t}
    end
    
    #.........................................................................................................
    def notes
      @notes ||= item.notes(self)
    end
  
    #.........................................................................................................
    def sum(a)
      a.inject(0) {|s,n| s+n}
    end
  
    #.........................................................................................................
    private :sum
  
  #### Progression
  end

#### Zgomot::Comp 
end
