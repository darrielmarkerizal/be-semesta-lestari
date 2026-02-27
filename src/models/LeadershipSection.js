const BaseModel = require('./BaseModel');

class LeadershipSection extends BaseModel {
  constructor() {
    super('leadership_section');
  }
}

module.exports = new LeadershipSection();
