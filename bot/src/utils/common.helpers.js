const parseJson = (json) => {
  try {
    return JSON.parse(json);
  } catch (e) {
    return undefined;
  }
};

module.exports = {
  parseJson
};
