const BaseModel = require('./BaseModel');

class Partner extends BaseModel {
  constructor() {
    super('partners');
  }
}

module.exports = new Partner();
