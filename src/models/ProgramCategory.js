const BaseModel = require('./BaseModel');

class ProgramCategory extends BaseModel {
  constructor() {
    super('program_categories');
  }
}

module.exports = new ProgramCategory();
