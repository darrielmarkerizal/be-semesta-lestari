const BaseModel = require('./BaseModel');

class HeroSection extends BaseModel {
  constructor() {
    super('hero_sections');
  }
}

module.exports = new HeroSection();
