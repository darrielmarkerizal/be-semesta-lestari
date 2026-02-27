const BaseModel = require('./BaseModel');

class HistorySection extends BaseModel {
  constructor() {
    super('history_section');
  }
}

module.exports = new HistorySection();
