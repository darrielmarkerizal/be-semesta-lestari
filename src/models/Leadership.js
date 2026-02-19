const BaseModel = require('./BaseModel');

class Leadership extends BaseModel {
  constructor() {
    super('leadership');
  }
}

module.exports = new Leadership();
