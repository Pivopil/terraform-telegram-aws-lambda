const config = require('../config');

module.exports = (bot) => {
  bot.inlineQuery(['start', 'help'], (ctx) => {
    const message = config.helpMessage;

    // results array containing 1 inlinequeryresult article for ctx.answerInlineQuery method
    const results = [
      {
        type: 'article',
        id: '1',
        title: 'Help Reference',
        input_message_content: {
          message_text: message
        },
        description: 'Sends help message on how to use the bot',
        reply_markup: {
          inline_keyboard: [
            [
              { text: 'Search Pixabay Image', switch_inline_query_current_chat: 'p ' }
            ],
            [
              { text: 'Search Wiki', switch_inline_query_current_chat: 'w ' }
            ]
          ]
        }
      }
    ];

    ctx.answerInlineQuery(results);
  });
};
