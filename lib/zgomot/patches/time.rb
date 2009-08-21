##############################################################################################################
module Zgomot  
  module CoreLibrary
    module TimePatches
    
      ####----------------------------------------------------------------------------------------------------
      module InstanceMethods
  
        #.......................................................................................................
        def truncate_to(tick_sec)
          tick_sec*(to_f/tick_sec).to_i
        end

      #### InstanceMethods
      end  
        
    #### ObjectPatches
    end
  ##### CoreLibrary
  end
#### AgentXmpp
end

##############################################################################################################
Time.send(:include, Zgomot::CoreLibrary::TimePatches::InstanceMethods)
