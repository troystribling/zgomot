##############################################################################################################
module Zgomot::Comp

  #####-------------------------------------------------------------------------------------------------------
  module Transforms

    #.........................................................................................................
    def repeat(times, opts={})
      (1..times).to_a.inject(Midi::Channel.create(opts[:chan])) do |c,i|
        patterns.kind_of?(Array) ? c + patterns : c << patterns
      end; self
    end

    #.........................................................................................................
    def time_shift(secs)
      patterns.each{|p| p.offset_time=secs}; self
    end

  #### Repeat
  end

#### Zgomot ::Comp
end
