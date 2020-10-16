const axios = require('axios');

const apikey = process.env.PIXABAYAPI;

module.exports = (bot) => {
  bot.inlineQuery(/p\s.+/, async (ctx) => {
    const input = ctx.inlineQuery.query.split(' '); // split string by spaces into array eg. ['p', 'search', 'term']
    input.shift(); // remove first element in array eg. ['search', 'term']
    const query = input.join(' '); // join elements in array into string separated by spaces eg. "search term"

    // call pixabay api with request using axios
    const res = await axios.get(`https://pixabay.com/api/?key=${apikey}&q=${query}&per_page=21`);
    // main data is stored in hits array in res.data
    const data = res.data.hits;

    // process the data using javascript's array map method to loop each element in array and return something as an element in the results array
    const results = data.map((item, index) => ({
      type: 'photo',
      id: String(index),
      photo_url: item.webformatURL,
      thumb_url: item.previewURL,
      photo_width: 300,
      photo_height: 200,
      caption: `[Source](${item.webformatURL})\n[Large Image](${item.largeImageURL})`,
      parse_mode: 'Markdown'
    }));
    ctx.answerInlineQuery(results);
  });
};
