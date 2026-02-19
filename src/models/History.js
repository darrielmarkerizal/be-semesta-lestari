const BaseModel = require('./BaseModel');

class History extends BaseModel {
  constructor() {
    super('history');
  }
}

module.exports = new History();
