const BaseModel = require('./BaseModel');

class HomeProgramsSection extends BaseModel {
  constructor() {
    super('home_programs_section');
  }
}

module.exports = new HomeProgramsSection();
