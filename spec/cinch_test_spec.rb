describe Cinch::Test do
  class MyPlugin
    include Cinch::Plugin

    attr_reader :foo
    def initialize(*)
      super
      @foo = config[:foo]
    end

    match /foo/, :method => :foo
    def foo(m)
      m.reply "foo: #{@foo}"
    end

    match /bar/, :method => :bar
    def bar(m)
      m.reply 'bar reply'
    end

    match /baz/, :method => :baz
    def baz(m)
      m.reply 'baz reply', true
    end

    listen_to :channel
    def listen(m)
      m.reply 'I listen'
    end

    match /trout/, :method => :action, :react_on => :action
    def action(m)
      m.reply 'I hate fish'
    end
  end

  include Cinch::Test

  it 'makes a test bot without a config' do
    bot = make_bot(MyPlugin)
    assert { bot.is_a? Cinch::Bot }
  end

  let(:bot) { make_bot(MyPlugin, :foo => 'foo_value') }

  it 'makes a test bot with a config' do
    assert { bot.is_a? Cinch::Bot }
  end

  it 'makes a bot with config values available to the plugin' do
    message = make_message(bot, '!foo')
    replies = get_replies(message)
    assert { replies == ['foo: foo_value'] }
  end

  describe '#make_message' do
    let(:message) { make_message(bot, '!bar') }

    it 'messages a test bot and gets a reply' do
      replies = get_replies(message)
      assert { replies == ['bar reply'] }
    end
  end

  describe '#make_message with reply' do
    let(:message) { make_message(bot, '!baz') }

    it 'messages a test bot and gets a prefixed reply' do
      replies = get_replies(message)
      assert { replies == ['test: baz reply'] }
    end
  end

  describe 'listeners' do
    let(:message) { make_message(bot, 'blah blah blah', :channel => 'test') }

    it 'messages a test bot and gets a prefixed reply' do
      replies = get_replies(message)
      assert { replies == ['I listen'] }
    end
  end
end
