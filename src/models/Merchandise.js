const BaseModel = require('./BaseModel');

class Merchandise extends BaseModel {
  constructor() {
    super('merchandise');
  }
}

module.exports = new Merchandise();
