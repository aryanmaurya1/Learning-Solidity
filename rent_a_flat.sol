pragma solidity  ^0.8.0.0;

contract EthBnb {
  
  address payable private landlordAddress;
  address payable private tenentAddress;

  struct Flat {
    uint256 priceInWei;
    address occupantAddress;
    bool flatIsAvailable;
  }

  Flat[8] private flatDB;

  modifier landlordOnly() {
    require(msg.sender == landlordAddress);
    _;
  }

  constructor() public {
    landlordAddress = msg.sender;
    for (uint i=0; i<8; i++) {
        flatDB[i].flatIsAvailable = true;
        if (i % 2 == 0) {
            flatDB[i].priceInWei = 0.2 ether;
        } else {
            flatDB[i].priceInWei = 0.1 ether;
        }
    }
  }

  function getFlatAvailability(uint _flatId)  public view returns (bool) {
    return flatDB[_flatId].flatIsAvailable;
  }

  function getPriceOfTheFlat(uint _flat) public view returns (uint) {
    return flatDB[_flat].priceInWei;
  }

  function getCurrentOccupant(uint _flat) public view returns (address) {
    return flatDB[_flat].occupantAddress;
  }

  function setFlatAvailability(uint _flat, bool _newAvailability) public landlordOnly {
    flatDB[_flat].flatIsAvailable = _newAvailability;
    if(_newAvailability) {
      flatDB[_flat].occupantAddress = address(0);
    }
  }

  function setPriceOfFlat(uint _flat, uint256 _price) public landlordOnly {
    flatDB[_flat].priceInWei = _price;
  }

  function rentAFlat(uint8 _flat) public payable returns (uint256) {
    tenentAddress = msg.sender;
    if(msg.value > 0 && flatDB[_flat].flatIsAvailable == true && msg.value % flatDB[_flat].priceInWei == 0) {
      uint256 nightsPaidFor = msg.value % flatDB[_flat].priceInWei;
      flatDB[_flat].flatIsAvailable = false;
      flatDB[_flat].occupantAddress = msg.sender;
      landlordAddress.transfer(msg.value);
      return nightsPaidFor;
    } else {
      tenentAddress.transfer(msg.value);
      return 0;
    }
  }
}
