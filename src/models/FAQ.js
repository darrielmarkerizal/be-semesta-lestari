const BaseModel = require('./BaseModel');

class FAQ extends BaseModel {
  constructor() {
    super('faqs');
  }
}

module.exports = new FAQ();
