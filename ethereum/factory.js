import web3 from './web3';

import CryptoFactory from './build/CryptoCoupon.solCryptoCouponFactory.json';

const instance = new web3.eth.Contract(
  JSON.parse(CryptoFactory.interface),
  '0x47BBb229CA348E90767558516f1676829CfF21EC'
); 

export default instance;
