const BaseModel = require('./BaseModel');

class Program extends BaseModel {
  constructor() {
    super('programs');
  }
}

module.exports = new Program();
