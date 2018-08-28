const routes = require('next-routes')();

routes
  .add('/cryptoCoupons/new', '/cryptoCoupons/new')
  .add('/cryptoCoupons/advancedcoupon/new', '/cryptoCoupons/advancedcoupon/new')
  .add('/cryptoCoupons/:address', '/cryptoCoupons/show')


module.exports = routes;
