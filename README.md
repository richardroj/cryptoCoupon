# cryptoCoupon

cd cryptoCoupon
npm install --save ganache-cli mocha solc fs-extra web3@1.0.0-beta.26

---

cd ethereum
node compile.js

---

cd cryptoCoupon
npm install --save truffle-hdwallet-provider

---
start ganache-cli in another console tab


cd ethereum 
node deploy.js

Should result in contract deployment
Copy the address from "contract deployed to 0x..." to ADDRESS file
and also to "Factory.js" - i.e. underneath JSON.parse(CryptoCouponFactory.interface)

---

cd cryptoCoupon
npm install --save next@4.1.4 react react-dom

---

cd cryptoCoupon
npm run dev

Should state "Ready on localhost:3000" if all is well!
