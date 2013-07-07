module Zgomot::Comp

  class Markov

    class << self
      def mark
        new
      end
    end

    attr_reader :current_state, :states

    def initialize
      @current_state, @states = 0, []
    end

    def add(trans, &blk)
      @states << {:trans=>sum_trans(trans), :blk => blk}
    end

    def init(state, args={})
      @current_state = state
      states[@current_state][:blk].call(args)
    end

    def next(args={})
      r, state = rand, states[@current_state]
      @current_state = state[:trans].select{|t| r >= t}.count
      Zgomot.logger.info "CURRENT MARKOV STATE: #{current_state}"
      blk = states[@current_state][:blk]
      blk.arity > 0 ? blk.call(args) : blk.call
    end

    def sum_trans(trans)
      sums = []; trans.each_index{|i| sums[i] = trans[0..i].inject(0){|s,v| s+v}}; sums
    end

    private :sum_trans

  end

end
