
pragma solidity 0.4.24;

import '../Math/SafeMath.sol'; 

/**
 * This is base ERC20 Contract , basically ERC-20 defines a common list of rules for all Ethereum tokens to follow
 */ 

contract ERC20 is Pausable{
  
  using SafeMath for uint256;

  //This creates an array with all balances 
  mapping (address => uint256) public balanceOf;
  mapping (address => mapping (address => uint256)) public allowed;  
    
  // public variables of the token  
  string public name;
  string public symbol;
  uint8 public decimals = 18;
  uint256 public totalSupply;
   
  // This notifies client about the approval done by owner to spender for a given value
  event Approval(address indexed owner, address indexed spender, uint256 value);

  // This notifies client about the approval done
  event Transfer(address indexed from, address indexed to, uint256 value);

   
  constructor (uint256 _initialSupply,string _tokenName, string _tokenSymbol) public {    
    totalSupply = _initialSupply * 10 ** uint256(decimals); // Update total supply with the decimal amount     
    balanceOf[msg.sender] = totalSupply;  
    name = _tokenName;
    symbol = _tokenSymbol;   
  }
  
    /* This function is used to transfer tokens to a particular address 
     * @param _to receiver address where transfer is to be done
     * @param _value value to be transferred
     */
	function transfer(address _to, uint256 _value) public whenNotPaused returns (bool)  {      
        require(balanceOf[msg.sender] > 0);                     
        require(balanceOf[msg.sender] >= _value);                   // Check if the sender has enough  
        require(_to != address(0));                                 // Prevent transfer to 0x0 address. Use burn() instead
        require(_value > 0);	
        require(_to != msg.sender);                                 // Check if sender and receiver is not same
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);  // Subtract value from sender
        balanceOf[_to] = balanceOf[_to].add(_value);                // Add the value to the receiver
        emit Transfer(msg.sender, _to, _value);                     // Notify all clients about the transfer events
        return true;
	}

	/* Send _value amount of tokens from address _from to address _to
     * The transferFrom method is used for a withdraw workflow, allowing contracts to send
     * tokens on your behalf
     * @param _from address from which amount is to be transferred
     * @param _to address to which amount is transferred
     * @param _amount to which amount is transferred
     */
    function transferFrom(
         address _from,
         address _to,
         uint256 _amount
     ) public whenNotPaused returns (bool success)
      { 
        require(balanceOf[_from] >= _amount);
        require(allowed[_from][msg.sender] >= _amount);
        require(_amount > 0);
        require(_to != address(0));           
        require(_from!=_to);   
        balanceOf[_from] = balanceOf[_from].sub(_amount);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
        balanceOf[_to] = balanceOf[_to].add(_amount);
        emit Transfer(_from, _to, _amount);
        return true;        
    }
    
    /* This function allows _spender to withdraw from your account, multiple times, up to the _value amount.
     * If this function is called again it overwrites the current allowance with _value.
     * @param _spender address of the spender
     * @param _amount amount allowed to be withdrawal
     */
     function approve(address _spender, uint256 _amount) public whenNotPaused  returns (bool success) {    
         require(msg.sender!=_spender);  
         allowed[msg.sender][_spender] = _amount;
         emit Approval(msg.sender, _spender, _amount);
         return true;
    } 

    /* This function returns the amount of tokens approved by the owner that can be
     * transferred to the spender's account
     * @param _owner address of the owner
     * @param _spender address of the spender 
     */
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
         return allowed[_owner][_spender];
    }
}