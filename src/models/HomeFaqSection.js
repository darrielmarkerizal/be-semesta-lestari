const BaseModel = require('./BaseModel');

class HomeFaqSection extends BaseModel {
  constructor() {
    super('home_faq_section');
  }
}

module.exports = new HomeFaqSection();
