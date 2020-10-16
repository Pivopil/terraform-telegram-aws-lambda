const config = require('../config');

module.exports = (bot) => {
  // handler for /start and /help command
  bot.command(['start', 'help'], (ctx) => {
    // set welcome message
    const message = config.helpMessage;

    // ctx.reply(text, [extra params])
    ctx.reply(message, {
      reply_markup: {
        inline_keyboard: [
          [
            // Use switch inline query current chat to pre-type "@s300bot p "
            { text: 'Search Pixabay Image', switch_inline_query_current_chat: 'p ' }
          ],
          [
            // Use switch inline query current chat to pre-type "@s300bot w "
            { text: 'Search Wiki', switch_inline_query_current_chat: 'w ' }
          ]
        ]
      }
    });
  });
};
