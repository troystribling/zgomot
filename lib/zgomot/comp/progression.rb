module Zgomot::Comp
  class Progression
    attr_reader :mode, :length, :velocity, :clock, :tonic, :items, :item
    def initialize(args)
      @length, @velocity, @item = [args[:length]].flatten, [args[:velocity]].flatten, args[:item]
      @items = (1..7).to_a
      self.mode!(args[:mode])
      @tonic = case args[:tonic]
                 when Array then args[:tonic]
                 when Symbol then [args[:tonic], 4]
                 when nil then [:C,4]
                 else raise(Zgomot::Error, "#{args[:tonic].inspect} is invalid tonic")
               end
    end
    def pitches
      last_pitch, octave = tonic; pitch = [last_pitch]
      mode[0..-2].each_index{|i| pitch << PitchClass.next(tonic.first, sum(mode[0..i]))}
      pitch[1..-1].map do |p|
        octave += 1 if p < last_pitch; last_pitch = p.value; [last_pitch, octave]
      end.unshift(tonic)
    end
    def new_respond_to?(meth, include_private=false)
      old_respond_to?(meth) || (not notes.select{|n| n.respond_to?(meth)}.empty?)
    end
    alias_method :old_respond_to?, :respond_to?
    alias_method :respond_to?, :new_respond_to?
    def method_missing(meth, *args, &blk)
      if not notes.select{|n| n.respond_to?(meth)}.empty?
        @notes = notes.map do |n|
                   n.respond_to?(meth) ? n.send(meth, *args, &blk) : n
                 end
      else
        @notes = nil
        items.send(meth, *args, &blk)
      end
      self
    end

    #.........................................................................................................
    # transforms
    #.........................................................................................................
    def tonic!(v)
      @notes = nil; @tonic = v; self
    end
    def mode!(v)
      @notes = nil; @mode = v.kind_of?(Mode) ? v : Mode.new(v); self
    end
    def octave!(oct)
      @notes = nil; @octave = oct; self
    end
    def [](*args)
      @items = args.flatten; self
    end
    def velocity=(v)
      notes.each{|n| n.velocity = v}
    end
    def length=(v)
      notes.each{|n| n.length = v}
    end

    #.........................................................................................................
    # midi interface
    def length_to_sec
      notes.inject(0.0){|s,n| s += n.length_to_sec}
    end
    def time=(time)
      @clock = Zgomot::Midi::Clock.new
      clock.update(time)
      notes.each do |n|
        n.time = clock.current_time
        clock.update(n.length_to_sec)
      end
    end
    def channel=(c)
      notes.each{|n| n.channel = c}
    end
    def to_midi
      notes.map{|n| n.to_midi}
    end
    def offset_time=(t)
      notes.each{|n| n.offset_time = t}
    end
    def to_ary
      notes
    end
    def notes
      @notes ||= item.notes(self)
    end

    def sum(a)
      a.inject(0) {|s,n| s+n}
    end

    private :sum
  end
end
