const routes = require('next-routes')();

routes
  .add('/cryptoCoupons/new', '/cryptoCoupons/new')
  .add('/cryptoCoupons/advancedcoupon/new', '/cryptoCoupons/advancedcoupon/new')
  .add('/cryptoCoupons/:address', '/cryptoCoupons/show')
  .add('/cryptoCoupons/:address/coupons', '/cryptoCoupons/coupons/index')
  .add('/cryptoCoupons/:address/coupons/new', '/cryptoCoupons/coupons/new');


module.exports = routes;
