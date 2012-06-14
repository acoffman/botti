module BotPlugin
  @plugins = []

  def initialize(muc, plugins)
    @muc = muc
    @plugin_instances = plugins
  end

  def process(time, nick, command)
    puts "warning: undefined process()"
  end

  def help_list(time, nick)
    puts "warning: undefined help_list()"
    return nil
  end

  def help(time, nick, command)
    puts "warning: undefined help()"
    return false
  end

  def self.included(base)
    @plugins << base
  end

  def self.plugins
    @plugins
  end


end
