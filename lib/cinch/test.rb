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
      def initialize(*)
        super
        @irc = MockIRC.new(self)

        # auugh why
        # this sets up instances of the plugins provided.
        # by default this is done in #start, which also
        # overrides @irc and calls @irc.start, which does
        # network i/o. :(
        @plugins.register_plugins(@config.plugins.plugins)
      end
    end

    class MockMessage < Cinch::Message
      def initialize(msg, bot, opts={})
        # override the message-parsing stuff
        super(nil, bot)
        @message = msg
        @user = Cinch::User.new(opts.delete(:nick) { 'test' }, bot)
        @bot.user_list.find_ensured(nil, @user.nick, nil)

        @channel = opts.delete(:channel) { nil }
      end
    end

    def make_bot(plugin, opts, &b)
      MockBot.new do
        configure do |c|
          c.nick = 'testbot'
          c.server = nil
          c.channels = []
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

    def send_message(message, event=:message)
      handlers = message.bot.handlers
      handlers.dispatch(event, message)

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
        define_method :reply do |r, prefix = false|
          r = [self.user.nick, r].join(': ') if prefix
          mutex.synchronize { replies << r }
        end
      end

      send_message(message, event)

      replies
    end
  end
end
