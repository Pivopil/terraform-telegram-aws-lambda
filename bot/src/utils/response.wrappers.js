const wrap = (code, data) => ({
  statusCode: code,
  body: data && JSON.stringify(data)
});

const success = (data) => wrap(200, data);
const failure = (message) => wrap(500, { message });

module.exports = {
  success,
  failure
};
