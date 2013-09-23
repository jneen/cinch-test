require 'cinch'

require 'pathname'
require 'thread'

load Pathname.new(__FILE__).dirname.join('test/version.rb')

module Cinch
  module Test
    class MockIRC < Cinch::IRC
      def initialize(*)
        super
        # the #setup method adds the @network property among
        # other things
        setup
      end

      # @override
      # never try to actually connect to a network
      def connect
        @bot.loggers.info('mock irc: not connecting')
      end
    end

    class MockBot < Cinch::Bot
      attr_accessor :mask

      def initialize(*)
        super
        @irc = MockIRC.new(self)

        # auugh why
        # this sets up instances of the plugins provided.
        # by default this is done in #start, which also
        # overrides @irc and calls @irc.start, which does
        # network i/o. :(
        @plugins.register_plugins(@config.plugins.plugins)

        # set the bot's hostmask
        @mask = 'foo!bar@baz'
      end
    end

    class MockMessage < Cinch::Message
      def initialize(msg, bot, opts={})
        # override the message-parsing stuff
        super(nil, bot)
        @message = msg
        @user = Cinch::User.new(opts.delete(:nick) { 'test' }, bot)
        @channel = Cinch::Channel.new(opts.delete(:channel), bot) if opts.key?(:channel)

        # set the message target
        @target = @channel || @user

        @bot.user_list.find_ensured(nil, @user.nick, nil)
      end
    end

    def make_bot(plugin, opts = {}, &b)
      MockBot.new do
        configure do |c|
          c.nick = 'testbot'
          c.server = nil
          c.channels = ['foo']
          c.plugins.plugins = [plugin]
          c.plugins.options[plugin] = opts
          c.reconnect = false
        end

        instance_eval(&b) if b
      end
    end

    def make_message(bot, text, opts={})
      MockMessage.new(text, bot, opts)
    end

    def send_message(message, event = :message)
      handlers = message.bot.handlers

      # Deal with secondary event types
      # See http://rubydoc.info/github/cinchrb/cinch/file/docs/events.md
      events = [:catchall, event]

      # If the message has a channel add the :channel event
      events << :channel unless message.channel.nil?

      # If the message is :private also trigger :message
      events << :message if events.include?(:private)

      # Dispatch each of the events to the handlers
      events.each { |e| handlers.dispatch(e, message) }

      # join all of the freaking threads, like seriously
      # why is there no option to dispatch synchronously
      handlers.each do |handler|
        handler.thread_group.list.each(&:join)
      end
    end

    def get_replies(message, event=:message)
      mutex = Mutex.new

      replies = []

      (class << message; self; end).class_eval do
        [ :reply, :safe_reply ].each do |name|
          define_method name do |r, prefix = false|
            r = [self.user.nick, r].join(': ') if prefix
            r = Cinch::Utilities::String.filter_string(r) if name == :safe_reply
            mutex.synchronize { replies << r }
          end
        end

        [ :action_reply, :safe_action_reply ].each do |name|
          define_method name do |r|
            r = Cinch::Utilities::String.filter_string(r) if name == :safe_action_reply
            mutex.synchronize { replies << r }
          end
        end
      end

      send_message(message, event)

      replies
    end
  end
end
