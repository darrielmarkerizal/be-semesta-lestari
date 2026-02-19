const BaseModel = require('./BaseModel');

class ClosingCTA extends BaseModel {
  constructor() {
    super('closing_ctas');
  }
}

module.exports = new ClosingCTA();
