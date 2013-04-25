describe Cinch::Test do
  class MyPlugin
    include Cinch::Plugin

    match /foo/, :method => :foo
    match /bar/, :method => :bar

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
end
