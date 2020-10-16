const Telegraf = require('telegraf');
const { parseJson } = require('../utils/common.helpers');
const { success, failure } = require('../utils/response.wrappers');

const bot = new Telegraf(process.env.TELEGRAM_BOT_KEY);



require('../commands/start')(bot);
require('../inlinehandlers/start')(bot);
require('../inlinehandlers/image')(bot);
require('../inlinehandlers/wiki')(bot);



const lambda = async (payload) => bot.handleUpdate(payload);

const handler = async ({ body }) => {
  try {
    const payload = parseJson(body);
    console.log('Got payload');
    console.log(payload);
    await lambda(payload);
    return success({});
  } catch ({ message }) {
    console.log('Failed to complete lambda');
    console.log(message);
    return failure(message);
  }
};

module.exports = {
  handler,
  lambda
};

// bot.use((ctx, next) => {
//     // console.log(ctx.message)
//     // ctx.reply("This is a bot!");
//     next(ctx);
// })

// bot.launch();
