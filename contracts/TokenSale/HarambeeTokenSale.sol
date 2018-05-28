pragma solidity ^0.4.11;

import '../Token/Owned.sol';
import '../Math/SafeMath.sol'; 


/**
 This is interface to transfer Harambee tokens , created by HARAMBEE token contract
 */
interface HarambeeToken {
    function transfer(address _to, uint256 _value) public returns (bool);
}


/**
 * This is the main Harambee Token Sale contract
 */
contract HarambeeTokenSale is Owned {

using SafeMath for uint256;

mapping (address=> uint256) investors;
    
// start and end timestamps when investments are allowed  (both inclusive)
uint256 public presalestartTime = 1525143600 ;     //1st may 6:00 am EAT
uint256 public presaleendTime = 1527735600 ;       //31st may 6:00 am EAT
uint256 public publicsalestartTime = 1530414000 ;  //1st july 6:00 am EAT
uint256 public publicsalesendTime = 1533006000 ;   //31st july 6:00 am EAT

// address where all funds collected from token sale are stored , this will ideally be address of MutliSig wallet
address wallet;

// amount of raised money in wei
uint256 public weiRaised;

// The token being sold
HarambeeToken public token;

bool hasPreTokenSaleCapReached = false;
bool hasPublicTokenSaleCapReached = false;

/**
  * event for funds received logging
  * @param investor who invested for the tokens     
  */
event InvestmentReceived(address indexed investor,uint256 value) ;


function HarambeeTokenSale(HarambeeToken _addressOfRewardToken, address _wallet) public {        
  require(presalestartTime >= now); 
  require(_wallet != address(0));   
    
  token = HarambeeToken (_addressOfRewardToken);
  wallet = _wallet;
  
  owner = msg.sender;
}

// fallback function  used to buy tokens , this function is called when anyone sends ether to this contract
function ()  payable public {  

  require(msg.sender != address(0));                     //investors address should not be zero
  require(msg.value != 0);                               //investment amount should be greater then zero            
  require(isInvestementAllowed());                       //Valid time of investment and cap has not been reached

  //forward fund received to Harambee multisig Account
  forwardFunds();            

  // Add to investments with the investor
  investors[msg.sender] = investors[msg.sender].add(msg.value);
  weiRaised = weiRaised.add(msg.value);

  //Notify server that an investment has been received
  InvestmentReceived(msg.sender,msg.value);
}

/**
 * This function is used to check if an investment is allowed or not
 */
function isInvestementAllowed() public view returns (bool) {
     if (isPreSaleActive())
       return (!hasPreTokenSaleCapReached);
     if (isPublicSaleActive())  
       return  (!hasPublicTokenSaleCapReached);
    
       return false;
}

// send ether to the fund collection wallet  , this ideally would be an multisig wallet
function forwardFunds() internal {
  wallet.transfer(msg.value);
}

//Whiteisting is 6 hours before the start time
function isPreSaleActive() internal view returns (bool) {
 return ((now >= presalestartTime) && (now < presaleendTime));  
}

//Pre Token Sale time
function isPublicSaleActive() internal view returns (bool) {
 return ((now >= publicsalestartTime) && (now <= publicsalesendTime));  
}    

// Called by owner when preico token cap has been reached
function preTokenSaleTokenSalesCapReached() public onlyOwner {
 if (!hasPreTokenSaleCapReached) 
 hasPreTokenSaleCapReached = true;
}

// Called by owner when ico token cap has been reached
function publicTokenSalesCapReached() public onlyOwner {
 if (!hasPublicTokenSaleCapReached)
 hasPublicTokenSaleCapReached = true;
}

//This function is used to transfer token to investor after successful audit
function transferToken(address _investor, uint _numberOfTokens) public onlyOwner {
      require(_numberOfTokens > 0);
      require(_investor != 0);
      require(_investor != msg.sender);
      token.transfer(_investor, _numberOfTokens);
}

}
