class Loader
  include BotPlugin
  def initialize(muc, plugins)
    @plugins = plugins
    super(muc, plugins)
  end

  def process(time, nick, command)
    return false unless command =~ /^(load|unload) /
      cmd,plugin = command =~ /^(load|unload) (.*)/ && [$1, $2]
    self.send(cmd, plugin, nick)
  end

  def help_list(time, nick)
    'load/unload [plugin_path]'
  end

  def help(time, nick, command)
    return false unless command =~/^(load|unload)$/
      @muc.say("#{nick}: loads or unloads plugins on the fly. give it the relative path to your plugin file")
    return true
  end

  private
  def load(plugin_path, nick)
    resp = @muc.load_plugin(plugin_path)
    @muc.say "#{nick}: #{resp}"
    true
  end

  def unload(plugin, nick)
    deleted = []
    @plugins.delete_if do |p|
      if p.class.to_s.downcase == plugin.to_s.downcase
        deleted << p.class
        true
      else
        false
      end
    end
    if deleted.size > 0
      @muc.say("#{nick}: unloaded #{deleted.join(", ")}")
    else
      @muc.say("#{nick}: sorry, no plugins match that name")
    end
    true
  end
end
