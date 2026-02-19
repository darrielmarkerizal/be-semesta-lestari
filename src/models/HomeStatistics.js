const BaseModel = require('./BaseModel');

class HomeStatistics extends BaseModel {
  constructor() {
    super('home_statistics');
  }
}

module.exports = new HomeStatistics();
