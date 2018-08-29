import web3 from './web3';

import CryptoFactory from './build/CryptoCoupon.solCryptoCouponFactory.json';

const instance = new web3.eth.Contract(
  JSON.parse(CryptoFactory.interface),
  '0x841924991E93cE06Ae8abb052E0B6d4CdA9d4b30'
); 

export default instance;
