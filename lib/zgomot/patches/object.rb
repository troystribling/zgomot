##############################################################################################################
module Zgomot  
  module CoreLibrary
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
  ##### CoreLibrary
  end
#### AgentXmpp
end

##############################################################################################################
Object.send(:include, Zgomot::CoreLibrary::ObjectPatches::InstanceMethods)
