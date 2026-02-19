const BaseModel = require('./BaseModel');

class ImpactSection extends BaseModel {
  constructor() {
    super('impact_sections');
  }
}

module.exports = new ImpactSection();
