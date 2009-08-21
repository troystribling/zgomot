##############################################################################################################
module Zgomot

  #####-------------------------------------------------------------------------------------------------------
  class Error < Exception; end

  #.........................................................................................................
  VERSION = "0.0.0"
  PLAY_DELAY = 1.0
  DISPATCHER_POLL = 1.0

  #.........................................................................................................
  DEFAULT_CONFIG = {
    :beats_per_minute => 120,
    :time_signature   => '4/4',
    :resolution       => '1/32'
  }

  #.........................................................................................................
  @config_file = "zgomot.yml"
  @app_path = File.dirname($0)
  @log_file = STDOUT
  @live = false
  
  ####......................................................................................................
  class << self

    #.......................................................................................................
    attr_accessor :config_file, :app_path, :log_file, :config, :live

    #.......................................................................................................
    def logger; @logger ||= Logger.new(STDOUT); end
    def logger=(logger); @logger = logger; end

    #.......................................................................................................
    def add_path(dir)
      File.join(Zgomot.app_path, dir)
    end

  #### self
  end

  #.......................................................................................................
  @config_file = add_path(config_file)
  user_config = if File.exist?(config_file)
                  (c = File.open(config_file) {|yf| YAML::load(yf)}) ? c : {}
                else; {}; end
  @config = DEFAULT_CONFIG.inject({}){|r,(k,v)| r.update(k => (user_config[k.to_s] || v))}         
  Zgomot.logger.info "CONFIGURATION: #{Zgomot.config.inspect}"    
                          
end

