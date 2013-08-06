set_config(:beats_per_minute=>120, :time_signature=>"4/4", :resolution=>"1/64")

add_input("nanoKONTROL") if sources.include?("nanoKONTROL")
add_cc(:mode, 17, :type => :cont, :min => 0, :max => 6, :init => 0)
add_cc(:reverse, 13, :type => :switch)

str 'input', np([:A,4],6,:l=>4)[1,3,5,2], :ch=>0 do |pattern|
  if cc(:reverse)
    pattern.mode!(cc(:mode).to_i).reverse!
  else
    pattern.mode!(cc(:mode).to_i)
  end
end

str 'chords', cp([:B,3],:ionian,:l=>4)[1,4,5,5], :lim=>6, :ch=>1 do |pattern|
  pattern
end

