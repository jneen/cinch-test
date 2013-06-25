describe Cinch::Test do
  class MyPlugin
    include Cinch::Plugin

    match /foo/, :method => :foo
    match /bar/, :method => :bar
    match /baz/, :method => :baz

    attr_reader :foo
    def initialize(*)
      super
      @foo = config[:foo]
    end

    def foo(m)
      m.reply "foo: #{@foo}"
    end

    def bar(m)
      m.reply 'bar reply'
    end

    def baz(m)
      m.reply 'baz reply', true
    end
  end

  include Cinch::Test

  let(:bot) { make_bot(MyPlugin, :foo => 'foo_value') }

  it 'makes a test bot' do
    assert { bot.is_a? Cinch::Bot }
  end

  describe '#make_message' do
    let(:message) { make_message(bot, '!foo') }
    let(:replies) { get_replies(message) }

    it 'messages a test bot' do
      replies = get_replies(message)
      assert { replies == ['foo: foo_value'] }
    end
  end

  describe '#make_message with reply' do
    let(:message) { make_message(bot, '!baz') }
    let(:replies) { get_replies(message) }

    it 'messages a test bot' do
      replies = get_replies(message)
      assert { replies == ['nick: baz reply'] }
    end
  end
end
