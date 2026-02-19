const BaseModel = require('./BaseModel');

class Mission extends BaseModel {
  constructor() {
    super('missions');
  }
}

module.exports = new Mission();
