##############################################################################################################
module Zgomot::Midi

  #####-------------------------------------------------------------------------------------------------------
  class Channel

    #####-------------------------------------------------------------------------------------------------------
    class << self
      
      #.........................................................................................................
      @channels = []

      #.........................................................................................................
      attr_reader :channels

      #.........................................................................................................
      def create(channel=nil)
        channels << new(aquire_channel(channel))
      end

      #.........................................................................................................
      def aquire_channel(channel=nil)
        if channel
          raise ZgomotError "1<= channel <= 16" if channel > 15 or channel < 1
          if channels.include?(channel)
            raise ZgomotError "channel #{channel} in use" 
          else
            channels << channel; channel
          end 
        else
          channel = (1..16).to_a.inject(nil){|c,i| channels.include?(i) ? c : c = i}
          raise ZgomotError "channel #{channel} in use" unless channel; channel
        end
      end

      #.........................................................................................................
      def release_channel(channel)
        channels.delete_if{|c| c = channel}
      end

    #### self
    end
    
    #####-------------------------------------------------------------------------------------------------------
    attr_reader :channel, :clock
    
    #.........................................................................................................
    def intitialize(channel)
      @channel = channel
      @clock = Clock.new
      @notes = []
    end

    #.........................................................................................................
    def notes
      @notes.flatten.compact 
    end
    
    #.........................................................................................................
    def <<(n)
      add_note(n)
    end

    #.........................................................................................................
    def +(notes)
      raise ArgumentError "note must be Array" unless n.kind_of?(Array)
      notes.each {|n| add_note(n)}
    end
    
    #.........................................................................................................
    def method_missing(method, *args, &blk )
      return @notes.send(method, *args, &blk)
    end

  private
  
  #.........................................................................................................
  def add_note(n)
    raise ArgumentError "note must be Hash" unless n.kind_of?(Hash)
    raise ArgumentError "note pitch must be specified" unless n[:p]
    pitch_class = [n[:p]].flatten.first
    note = Note.new(:pitch => n[:p], :length => n[:l], :velocity => n[:v], :time => clock.current_time)
    @notes << note unless pitch_class.eql?(:R)
    clock.update(note.sec)
  end
  
  #### Channel
  end

#### Zgomot::Comp 
end
