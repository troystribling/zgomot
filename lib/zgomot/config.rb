##############################################################################################################
module Zgomot

  #####-------------------------------------------------------------------------------------------------------
  class ZgomotError < Exception; end

  #.........................................................................................................
  VERSION = "0.0.0"

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

  #.........................................................................................................
  OptionParser.new do |opts|
    opts.banner = 'Usage: agent_xmpp.rb [options]'
    opts.separator ''
    opts.on('-c', '--config config.yml', 'YAML agent configuration file relative to application path') {|f| config_file = f}
    opts.on('-f', '--logfile file.log', 'name of logfile') {|f| log_file = f}
    opts.on('-l', '--logfile file.log', 'name of logfile') {|l| live = true}
    opts.on_tail('-h', '--help', 'Show this message') {
      puts opts
      exit
    }
    opts.parse!(ARGV)
  end

  #.......................................................................................................
  @config_file = add_path(config_file)
  user_config = if File.exist?(config_file)
                  (c = File.open(config_file) {|yf| YAML::load(yf)}) ? c : {}
                else; {}; end
  @config = DEFAULT_CONFIG.inject({}){|r,(k,v)| r.update(k => (user_config[k.to_s] || v))}         
                          
end

