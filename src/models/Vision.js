const BaseModel = require('./BaseModel');

class Vision extends BaseModel {
  constructor() {
    super('visions');
  }
}

module.exports = new Vision();
