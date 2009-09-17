##############################################################################################################
module Zgomot::Comp

  #####-------------------------------------------------------------------------------------------------------
  class Note

    #####-------------------------------------------------------------------------------------------------------
    # progession interface
    #####-------------------------------------------------------------------------------------------------------
    class Progression

      #.........................................................................................................
      def notes(prog)
        count = -1
        prog.items.map do |d| 
          count += 1; idx_length, idx_velocity = count % prog.length.length, count % prog.velocity.length
          pitch = d.eql?(:R) ? :R : prog.pitches[d-1]
          Zgomot::Midi::Note.new(:pitch => pitch, :length => prog.length[idx_length], :velocity => prog.velocity[idx_velocity])
        end
      end
    
    #### Progression  
    end
      
  #### Note
  end

#### Zgomot::Comp 
end
