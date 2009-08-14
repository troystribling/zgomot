##############################################################################################################
module Zgomot::Midi

  #####-------------------------------------------------------------------------------------------------------
  class Channel

    #.........................................................................................................
    include Transforms
    
    #####-------------------------------------------------------------------------------------------------------
    class << self
      
      #.........................................................................................................
      @channels = []

      #.........................................................................................................
      attr_reader :channels

      #.........................................................................................................
      def chize(pattern, opts={})
        channels << new(pattern, aquire_channel(opts[:chan]))
      end

      #.........................................................................................................
      def aquire_channel_number(number=nil)
        if number
          raise ZgomotError "1<= channel <= 16" if number > 15 or number < 1
          if not channels.select{|c| c.number.eql?(number)}.empty?
            raise ZgomotError "channel #{number} in use" 
          else; number; end 
        else
          number = (1..16).to_a.inject(nil){|c,i| channels.select{|c| c.number.eql?(i)}.empty? ? c = i : c}
          raise ZgomotError "channel #{number} in use" unless number; number
        end
      end

      #.........................................................................................................
      def release_channel(chan)
        channels.delete_if{|c| c.number = chan.number}
      end

    #### self
    end
    
    #####-------------------------------------------------------------------------------------------------------
    attr_reader :number, :clock, :pattern
    
    #.........................................................................................................
    def intitialize(pattern, number)
      @pattern = pattern
      @number = number
      @clock = Clock.new
      @notes = []
      self << pattern
    end

    #.........................................................................................................
    def notes
      @notes.flatten.compact 
    end
    
    #.........................................................................................................
    def <<(item)
      add_at_time(item)
    end

    #.........................................................................................................
    def +(items)
      raise ArgumentError "must be Array" unless items.kind_of?(Array)
      items.each {|n| add_at_time(n)}
    end
    
    #.........................................................................................................
    def method_missing(method, *args, &blk )
      return @notes.send(method, *args, &blk)
    end

  private
  
  #.........................................................................................................
  def add_at_time(item)
    items = [item].flatten
    items.flatten.each do |n|
      raise ArgumentError "must be Zgomot::Midi::Note" unless n.kind_of?(Zgomot::Midi::Note)  
      if n.pitch_class.eql?(:R)    
        n.time = clock.current_time
        @notes << note unless
      end
    end    
    clock.update(items.first.sec)
  end
  
  #### Channel
  end

#### Zgomot::Comp 
end
