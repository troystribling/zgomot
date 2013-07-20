# example stream to be imported into zgomot shell

add_input("nanoKONTROL")
add_cc(:mode, 17, :type => :cont, :min => 0, :max => 6, :init => 0)
add_cc(:reverse, 13, :type => :switch)


str 'simple_input', np([:A,4],2,:l=>4)[7,5,3,1] do |pattern|
  ch << if cc(:reverse)
          pattern.mode!(cc(:mode).to_i).reverse!
        else
          pattern.mode!(cc(:mode).to_i)
        end
end

