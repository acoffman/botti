#!/usr/bin/ruby

require 'yaml'
require 'xmpp4r'
require 'xmpp4r/muc/helper/simplemucclient'

require File.dirname(__FILE__) + "/plugin"

$CONFIG = YAML.load_file(ARGV[0] || 'config.yml')['botti']

bot_nick = $CONFIG['bot_nick']
room_id = [$CONFIG['room_id'], $CONFIG['bot_nick']].join("/")

$CONFIG['plugins'].each do |plugin|
  begin
      require File.dirname(__FILE__) + "/" + plugin
  rescue LoadError => e
      STDERR.puts "#{plugin} not loaded - #{e.message}"
  end
end

# connect and authenticate with the server
client = Jabber::Client.new(Jabber::JID::new($CONFIG['jabber_id']))
client.connect
client.auth($CONFIG['password'])
muc = Jabber::MUC::SimpleMUCClient.new(client)

loaded_plugins = []
BotPlugin.plugins.each { |p| loaded_plugins << p.new(muc, loaded_plugins) }

# set up callback
muc.on_message do |time,nick,text|
  next unless command = text =~ /^#{bot_nick}: (.*)/i && $1.strip
  muc.say("unrecognized command. \"help\" for a list.") unless loaded_plugins.inject(false){|found,p| p.process(time, nick, command) || found }
end

# join the room
muc.join Jabber::JID.new(room_id)

# just chill until killed
begin
  while true do
    sleep(1)
  end
  rescue Interrupt => e
    muc.exit
    client.close
end

