##############################################################################################################
module Zgomot  
  module StandardLibrary
    module ObjectPatches
    
      ####----------------------------------------------------------------------------------------------------
      module InstanceMethods
  
        #.......................................................................................................
        def define_meta_class_method(name, &blk)
          (class << self; self; end).instance_eval {define_method(name, &blk)}
        end

      #### InstanceMethods
      end  
        
    #### ObjectPatches
    end
  ##### StandardLibrary
  end
#### AgentXmpp
end

##############################################################################################################
Object.send(:include, Zgomot::StandardLibrary::ObjectPatches::InstanceMethods)
