const BaseModel = require('./BaseModel');

class DonationCTA extends BaseModel {
  constructor() {
    super('donation_ctas');
  }
}

module.exports = new DonationCTA();
