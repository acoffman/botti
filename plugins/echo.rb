class EchoPlugin
  include BotPlugin

  def initialize(muc, plugins)
    super(muc, plugins)
  end

  def process(time, nick, command)
    return false unless (command =~ /^echo /)
    msg = command =~ /^echo (.*)/ && $1
    @muc.say("#{nick}: #{msg}")
    return true
  end

  def help_list(time, nick)
    return "echo [something]"
  end

  def help(time, nick, command)
    return false unless command =~ /^echo$/
    @muc.say("#{nick}: echos what you wrote back to the chat room")
    return true
  end
end

