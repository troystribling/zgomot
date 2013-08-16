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
      old_respond_to?(meth) or
      notes.any?{|n| n.respond_to?(meth)} or
      (items.respond_to?(meth) and [:reverse!, :shift, :pop, :push, :unshift].include?(meth))
    end
    alias_method :old_respond_to?, :respond_to?
    alias_method :respond_to?, :new_respond_to?
    def method_missing(meth, *args, &blk)
      if item.respond_to?(meth)
        item.send(meth, *args, &blk)
      elsif notes.any?{|n| n.respond_to?(meth)}
        @notes = notes.map do |n|
                   n.respond_to?(meth) ? n.send(meth, *args, &blk) : n
                 end
      elsif items.respond_to?(meth)
        @notes = nil
        items.send(meth, *args, &blk)
      else
        raise(NoMethodError, "undefined method '#{meth}' called for #{self.class}")
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
      notes.each{|n| n.velocity = v}; self
    end
    def length=(v)
      notes.each{|n| n.length = v}; self
    end
    def note(number)
      notes.map{|n| n.note(number)}
    end

    #.........................................................................................................
    # midi interface
    #.........................................................................................................
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
    def offset=(t)
      notes.each{|n| n.offset = t}
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
