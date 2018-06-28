pragma solidity 0.4.24;

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

mapping (address=> uint256) contributors;
    
// start and end timestamps when contributions are allowed  (both inclusive)
uint256 public presalestartTime = 1525143600 ;     //1st may 6:00 am EAT
uint256 public presaleendTime = 1527735600 ;       //31st may 6:00 am EAT
uint256 public publicsalestartTime = 1530414000 ;  //1st july 6:00 am EAT
uint256 public publicsalesendTime = 1533006000 ;   //31st july 6:00 am EAT

// address where all funds collected from token sale are stored , this will ideally be address of MutliSig wallet
address wallet;

// amount of raised money in wei
uint256 public weiRaised = 0;

// The token being sold
HarambeeToken public token;

bool hasPreTokenSaleCapReached = false;
bool hasPublicTokenSaleCapReached = false;

/**
  * event for funds received logging
  * @param contributor who contributed for the tokens     
  */
event ContributionReceived(address indexed contributor,uint256 value) ;
event TokensTransferred(address indexed contributor, uint256 numberOfTokensTransferred);


function HarambeeTokenSale(HarambeeToken _addressOfRewardToken, address _wallet) public {        
  require(presalestartTime >= now); 
  require(_wallet != address(0));   
    
  token = HarambeeToken (_addressOfRewardToken);
  wallet = _wallet;
  
  owner = msg.sender;
}

// fallback function  used to buy tokens , this function is called when anyone sends ether to this contract
function ()  payable public {  

  require(msg.sender != address(0));                     //contributors address should not be zero
  require(msg.value != 0);                               //contribution amount should be greater then zero            
  require(isContributionAllowed());                      //Valid time of contribution and cap has not been reached

  //forward fund received to Harambee multisig Account
  forwardFunds();            

  // Add to contributions with the contributor
  contributors[msg.sender] = contributors[msg.sender].add(msg.value);
  weiRaised = weiRaised.add(msg.value);

  //Notify server that an contribution has been received
  ContributionReceived(msg.sender,msg.value);
}

/**
 * This function is used to check if an contribution is allowed or not
 */
function isContributionAllowed() public view returns (bool) {
     if (isPreSaleActive())
       return (!hasPreTokenSaleCapReached);
     else if (isPublicSaleActive())  
       return  (!hasPublicTokenSaleCapReached);
    
       return false;
}

// send ether to the fund collection wallet  , this ideally would be an multisig wallet
function forwardFunds() internal {
  wallet.transfer(msg.value);
}

//Check if pre sale is active or not
function isPreSaleActive() internal view returns (bool) {
 return ((now >= presalestartTime) && (now < presaleendTime));  
}

//Check if token sale is active or not
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

//This function is used to transfer token to contributor after successful audit
function transferToken(address _contributor, uint _numberOfTokens) public onlyOwner {
      require(_numberOfTokens > 0);
      require(_contributor != 0);
      require(_contributor != msg.sender);
      token.transfer(_contributor, _numberOfTokens);
      emit TokensTransferred(_contributor, _numberOfTokens);
}

//This function is used to do bulk transfer token to contributor after successful audit manually
  function manualBatchTransferToken(uint256[] amount, address[] wallets) public onlyOwner {
      for (uint256 i = 0; i < wallets.length; i++) {
        token.transfer(wallets[i], amount[i]);
        emit TokensTransferred(wallets[i], amount[i]);
      }
  }

}
