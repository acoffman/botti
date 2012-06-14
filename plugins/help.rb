class HelpPlugin
  include BotPlugin

  def initialize(muc, plugins)
    super(muc, plugins)
  end

  def process(time, nick, command)
    return false unless (command =~ /^help$/ or command =~ /^help /)

    if command =~ /^help$/
      # we want a listing
      helps = @plugin_instances.inject([]) { |helps, p| helps << p.help_list(time, nick) }
      @muc.say("#{nick}: #{helps.compact.join("\n")}")
    elsif msg = command =~ /^help (.*)/ && $1
      #we want a specific help
      found = @plugin_instances.inject(false) { |found, p| p.help(time, nick, msg) || found }
      @muc.say("#{nick}: no such command") unless found
    else
      return false
    end

    return true
  end

  def help_list(time, nick)
    return "help [topic]"
  end

  def help(time, nick, command)
    return false unless command =~ /^help$/
      @muc.say("#{nick}: help [topic]\nGet information on bot commands.")
    return true
  end

end

