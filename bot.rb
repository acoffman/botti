#!/usr/bin/ruby

require 'yaml'
require 'xmpp4r'
require 'xmpp4r/muc/helper/simplemucclient'
require 'pry'
require 'pry-nav'

require File.dirname(__FILE__) + "/plugin"

class ChatBot
  def initialize(config)
    @loaded_plugins = []
    @config = config
    connect
  end

  def connect
    # connect and authenticate with the server
    @client = Jabber::Client.new(Jabber::JID::new(@config['jabber_id']))
    @client.connect
    @client.auth(@config['password'])
    @muc = Jabber::MUC::SimpleMUCClient.new(@client)
    @bot_nick = @config['bot_nick']
    @room_id = [@config['room_id'], @config['bot_nick']].join("/")

    @config['plugins'].each {|p| load_plugin(p)}

    # set up callback
    @muc.on_message do |time,nick,text|
      begin
        next unless command = text =~ /^#{@bot_nick}: (.*)/i && $1.strip
        @muc.say("unrecognized command. \"help\" for a list.") unless @loaded_plugins.inject(false){|found,p| p.process(time, nick, command) || found }
      rescue => e
        binding.pry
      end
    end
    # join the room
    @muc.join Jabber::JID.new(@room_id)
  end

  def load_plugin(plugin_path)
    begin
      require File.dirname(__FILE__) + "/" + plugin_path
    rescue LoadError => e
      msg = "#{plugin_path} not loaded - #{e.message}"
      STDERR.puts msg
      return msg
    end
    return init_plugins
  end

  def unload_plugin
    BotPlugin.unload(plugin)
  end

  #stupid runtime complexity - fix
  def init_plugins
    BotPlugin.plugins.each do |p|
      unless @loaded_plugins.map{|x| x.class}.include? p
        @loaded_plugins << p.new(self, @loaded_plugins)
        return "loaded #{p}"
      end
    end
  end

  def say(msg)
    @muc.say(msg)
  end

  def close
    @muc.exit
    @client.close
  end
end

$CONFIG = YAML.load_file(ARGV[0] || 'config.yml')['botti']

begin
  @bot = ChatBot.new($CONFIG)
  while true do
    sleep(1)
  end
rescue Interrupt => e
  @bot.close
end
