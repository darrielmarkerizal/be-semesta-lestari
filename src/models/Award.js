const BaseModel = require('./BaseModel');

class Award extends BaseModel {
  constructor() {
    super('awards');
  }
}

module.exports = new Award();
