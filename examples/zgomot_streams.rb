# example stream to be imported into zgomot shell

add_input("nanoKONTROL")
add_cc(:mode, 17, :type => :cont, :min => 0, :max => 6, :init => 0)
add_cc(:reverse, 13, :type => :switch)


str 'input', np([:A,4],2,:l=>4)[7,5,3,1] do |pattern|
  ch(1) << if cc(:reverse)
             pattern.mode!(cc(:mode).to_i).reverse!
           else
             pattern.mode!(cc(:mode).to_i)
           end
end

str 'chords', cp([:B,3],:ionian,:l=>4)[1,4,5,5], :lim=>6 do |pattern|
  ch(2) << pattern
end

