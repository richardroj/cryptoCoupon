pragma solidity ^0.4.18;

import "./AccessControl.sol";
import "./ERC721.sol";
import "./SafeMath.sol";



contract DetailedERC721 is ERC721 {
    function name() public view returns (string _name);
    function symbol() public view returns (string _symbol);
}

/*  
    TO DO
    - Add conditionals for the 3 different types of assignment (lottery, lottery + fee, Selling)
    - Add function to generate multiple tokens (it should be approved)
    - Create burnToken function (it should be approved) 
    - Create the lottery function 
    
    P.S:  The implementERC721 function has been deleted from ERC721.sol and CryptoCoupons.sol , otherwise, we could not deploy the contract.
*/    

contract CryptoCouponFactory {
    address[] public deployedCryptoCoupons;

    function createCryptoCoupon(string name, address owner) public {
        address newCoupon = new CryptoCoupon(name, owner);
        deployedCryptoCoupons.push(newCoupon);
    }

    function getDeployedCryptoCoupons() public view returns (address[]) {
        return deployedCryptoCoupons;
    }
}


contract CryptoCoupon is AccessControl, DetailedERC721 {
    using SafeMath for uint256;
    address public owner;
    string public name;
    event TokenCreated(uint256 tokenId, string name, uint256 serialNumber, uint256 price, address owner);
    event TokenSold(
        uint256 indexed tokenId,
        string name,
        uint256 Price,
        address indexed oldOwner,
        address indexed newOwner
        );

    mapping (uint256 => address) private tokenIdToOwner;
    mapping (uint256 => uint256) private tokenIdToPrice;
    mapping (address => uint256) private ownershipTokenCount;
    mapping (uint256 => address) private tokenIdToApproved;
    //players to participate in the lottery
    address[] public players;
    constructor(string _name, address _creator) public {
        owner = _creator;
        name = _name;
    }
   
    struct Coupon {
        string name;
        string description;
        uint256 serialNumber;
        bool gift;
        uint fee;
        uint8 value;
    }

    Coupon[] public coupons;
    uint cont = 0;

    function createToken(string _name, string _description, uint256 _serialNumber, bool _gift, uint _fee, uint8 _value,
    address _owner, uint256 _price) public onlyCLevel {
        require(_owner != address(0));

        _createToken(_name, _description, _serialNumber, _gift, _fee, _value,
                _owner, _price);
        
    }
    //ASSIGNED DEFAULT TOKEN TO cooAddress
    function createToken(string _name, string _description, bool _gift, uint8 _value) public onlyCEO {
        //string memory _serialNumber = _appendUintToString("DEFAULT", cont);
        cont++;
        _createToken(_name, _description, 0, _gift, 0, _value,
              cooAddress, 0.01 ether);
    }
    //Se debe evaluar el gas consumido en lotes . If the remix crash, rise the gasLimit
     function createTokensBatch(string _name, string _description, bool _gift, uint8 _value, uint _numberOfTokens) public {
        for (uint i = 0; i < _numberOfTokens ; i++){
            _createToken(_name, _description, 0, _gift, 0, _value,
              cooAddress, 0.01 ether);
        }
        
    }
   
    function _createToken(string _name, string _description, uint256 _serialNumber, bool _gift, uint _fee,
            uint8 _value, address _owner, uint256 _price) private {
                _owner = owner;
        Coupon memory _Coupon = Coupon({
            name: _name,
            description: _description,
            serialNumber: coupons.length + 1,
            gift: _gift,
            fee:  _fee,
            value: _value
        });
        
        uint256 newTokenId = coupons.push(_Coupon) - 1;
        tokenIdToPrice[newTokenId] = _price;
    
        emit TokenCreated(newTokenId, _name, _serialNumber, _price, _owner);
        _transfer(address(0), _owner, newTokenId);
    }
    
    function getToken(uint256 _tokenId) public view returns (
        string _tokenName,
        string _tokenDescription,
        uint256 _tokenSerialNumber,
        bool _tokenGift,
        uint8 _tokenValue,
        address _owner,
        uint256 _price
        
    ) {
        _tokenName = coupons[_tokenId].name;
        _tokenDescription = coupons[_tokenId].description;
        _tokenSerialNumber = coupons[_tokenId].serialNumber;
        _tokenGift =coupons[_tokenId].gift;
        _tokenValue = coupons[_tokenId].value;
        _price = tokenIdToPrice[_tokenId];
        _owner = tokenIdToOwner[_tokenId];
    }
    
// tabla donde cada columna es un token generado
    function getAllTokens() public view returns (
        uint256[],
        uint256[],
        address[]
    ) {
        uint256 total = totalSupply();
        uint256[] memory ids = new uint256[](total);
        uint256[] memory prices = new uint256[](total);
        address[] memory owners = new address[](total);

        for (uint256 i = 0; i < total; i++) {
            ids[i] = i;
            prices[i] = tokenIdToPrice[i];
            owners[i] = tokenIdToOwner[i];
        }

        return (ids, prices, owners);
    }
    
    function getAllCouponIds() public view returns(uint256[]){
        uint256 total = coupons.length;
        uint256[] memory ids = new uint256[](total);

        for (uint256 i = 0; i < total; i++) {
            ids[i] = coupons[i].serialNumber;
            
        }

        return (ids);
    }
    
    
    function withdrawBalance(address _to, uint256 _amount) public onlyCEO {
        require(_amount <= address(this).balance);

        if (_amount == 0) {
            _amount = address(this).balance;
        }

        if (_to == address(0)) {
            ceoAddress.transfer(_amount);
        } else {
            _to.transfer(_amount);
        }
    }

    function purchase(uint256 _tokenId) public payable whenNotPaused {
        address oldOwner = ownerOf(_tokenId);
        address newOwner = msg.sender;
        uint256 sellingPrice = priceOf(_tokenId);

        require(oldOwner != address(0));
        require(newOwner != address(0));
        require(oldOwner != newOwner);
        require(!_isContract(newOwner));
        require(sellingPrice > 0);
        require(msg.value >= sellingPrice);

        _transfer(oldOwner, newOwner, _tokenId);
        //tokenIdToPrice[_tokenId] = nextPriceOf(_tokenId);
        emit TokenSold(
            _tokenId,
            coupons[_tokenId].name,
            sellingPrice,
            oldOwner,
            newOwner
        );

        uint256 excess = msg.value.sub(sellingPrice);
        uint256 contractCut = sellingPrice.mul(6).div(100); // 6% cut

        if (oldOwner != address(this)) {
            oldOwner.transfer(sellingPrice.sub(contractCut));
        }

        if (excess > 0) {
            newOwner.transfer(excess);
        }
    }

    function priceOf(uint256 _tokenId) public view returns (uint256 _price) {
        return tokenIdToPrice[_tokenId];
    }    
    
    function tokensOf(address _owner) public view returns(uint256[]) {
        uint256 tokenCount = balanceOf(_owner);
        if (tokenCount == 0) {
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 total = totalSupply();
            uint256 resultIndex = 0;

            for (uint256 i = 0; i < total; i++) {
                if (tokenIdToOwner[i] == _owner) {
                    result[resultIndex] = i;
                    resultIndex++;
                }
            }
            return result;
        }
    }

    function totalSupply() public view returns (uint256 _totalSupply) {
        _totalSupply = coupons.length;
    }

    function balanceOf(address _owner) public view returns (uint256 _balance) {
        _balance = ownershipTokenCount[_owner];
    }

    function ownerOf(uint256 _tokenId) public view returns (address _owner) {
        _owner = tokenIdToOwner[_tokenId];
    }

    function approve(address _to, uint256 _tokenId) public whenNotPaused {
        require(_owns(msg.sender, _tokenId));
        tokenIdToApproved[_tokenId] = _to;
        emit Approval(msg.sender, _to, _tokenId);
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) public whenNotPaused {
        require(_to != address(0));
        require(_owns(_from, _tokenId));
        require(_approved(msg.sender, _tokenId));

        _transfer(_from, _to, _tokenId);
    }
    // REGALAR UN COUPON
    function transfer(address _to, uint256 _tokenId) public whenNotPaused {
        require(_to != address(0));
        require(_owns(msg.sender, _tokenId));

        _transfer(msg.sender, _to, _tokenId);
    }

    function takeOwnership(uint256 _tokenId) public whenNotPaused {
        require(_approved(msg.sender, _tokenId));
        _transfer(tokenIdToOwner[_tokenId], msg.sender, _tokenId);
    }

    function name() public view returns (string _name) {
        _name = "Addidas";
    }

    function symbol() public view returns (string _symbol) {
        _symbol = "ADD";
    }

    function _owns(address _claimant, uint256 _tokenId) private view returns (bool) {
        return tokenIdToOwner[_tokenId] == _claimant;
    }

    function _approved(address _to, uint256 _tokenId) private view returns (bool) {
        return tokenIdToApproved[_tokenId] == _to;
    }

    function _transfer(address _from, address _to, uint256 _tokenId) private {
        ownershipTokenCount[_to]++;
        tokenIdToOwner[_tokenId] = _to;

        if (_from != address(0)) {
            ownershipTokenCount[_from]--;
            delete tokenIdToApproved[_tokenId];
        }

        emit Transfer(_from, _to, _tokenId);
    }
    
    function _appendUintToString(string inStr, uint v) private pure returns (string str) {
        uint maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint i = 0;
        while (v != 0) {
            uint remainder = v % 10;
            v = v / 10;
            reversed[i++] = byte(48 + remainder);
        }
        bytes memory inStrb = bytes(inStr);
        bytes memory s = new bytes(inStrb.length + i);
        uint j;
        for (j = 0; j < inStrb.length; j++) {
            s[j] = inStrb[j];
        }
        for (j = 0; j < i; j++) {
            s[j + inStrb.length] = reversed[i - 1 - j];
        }
        str = string(s);
    }
    
  function _burn(address _owner, uint256 _tokenId) internal {
    clearApproval(_owner, _tokenId);
    removeTokenFrom(_owner, _tokenId);
    emit Transfer(_owner, address(0), _tokenId);
  }


  function clearApproval(address _owner, uint256 _tokenId) internal {
    require(ownerOf(_tokenId) == _owner);
    if (tokenIdToApproved[_tokenId] != address(0)) {
      tokenIdToApproved[_tokenId] = address(0);
    }
  }


  function removeTokenFrom(address _from, uint256 _tokenId) internal {
    require(ownerOf(_tokenId) == _from);
    ownershipTokenCount[_from] = ownershipTokenCount[_from].sub(1);
    tokenIdToOwner[_tokenId] = address(0);
  }
     
    function _isContract(address addr) private view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
    
    // Entering to Lottery and allowing a player to participate just once
    function enterToLottery() public {
        require(!checkPlayerExists(msg.sender));
        players.push(msg.sender);
    }
    
    //to check player
    function checkPlayerExists(address player) public constant returns(bool){
      for(uint256 i = 0; i < players.length; i++){
         if(players[i] == player) return true;
      }
      return false;
   }
   //generate winner of token.
    function _winnerAddress() private view onlyCLevel returns(address) {
      //it depends of the condition
      //for now Generates a number between 1 and length of players that will be the winner
      uint256 numberGenerated = block.number % players.length + 1; // This isn't secure
      return players[numberGenerated];
   }
  // !!! if the _tokenId is already owned not by the CEO/COO could be a big problem 
   function generateWinnerOfToken(uint256 _tokenId) public onlyCLevel returns (address) {
        require(tokenIdToOwner[_tokenId] == ceoAddress || tokenIdToOwner[_tokenId] == ceoAddress);
        address playerWinner = _winnerAddress();
        transfer(playerWinner, _tokenId);
        return playerWinner;
   }
   

}