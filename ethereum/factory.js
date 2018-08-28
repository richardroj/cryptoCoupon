import web3 from './web3';

import CryptoFactory from './build/CryptoCoupon.solCryptoCouponFactory.json';

const instance = new web3.eth.Contract(
  JSON.parse(CryptoFactory.interface),
  '0xC77dC4F72c5b4a52a0CbC56EB3B7769da246C1b2'
); 

export default instance;
