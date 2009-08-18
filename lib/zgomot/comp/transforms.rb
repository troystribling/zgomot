##############################################################################################################
module Zgomot::Comp

  #####-------------------------------------------------------------------------------------------------------
  module Transforms

    #.........................................................................................................
    def repeat(times, opts={})
      (1..times).to_a.inject(Midi::Channel.create(opts[:chan])) do |c,i|
        notes.kind_of?(Array) ? c + notes : c << notes
      end; self
    end

    #.........................................................................................................
    def time_shift(secs)
      notes.each{|n| n.offset_time=secs+offset_time.to_f}; self
    end

  #### Repeat
  end

#### Zgomot ::Comp
end
