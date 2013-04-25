# Cinch::Test

## Usage

1. `require 'cinch/test'` and include the module `Cinch::Test` in your test scope
2. Make a bot with `make_bot(plugin, plugin_opts)` (you can pass a block to further configure the bot)
3. Make a message with `make_message(bot, 'message text')`
4. Stub things out on the message as you like, then collect all the replies
   with `get_replies(message)`
