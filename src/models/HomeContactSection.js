const BaseModel = require('./BaseModel');

class HomeContactSection extends BaseModel {
  constructor() {
    super('home_contact_section');
  }
}

module.exports = new HomeContactSection();
