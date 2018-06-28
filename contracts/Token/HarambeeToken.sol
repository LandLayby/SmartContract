
pragma solidity 0.4.24;

import './Owned.sol';
import './ERC20.sol';
import '../Math/SafeMath.sol'; 


//This is the Main Harambee Token Contract derived from the other two contracts Owned and ERC20
contract HarambeeToken is Owned, ERC20 {

    using SafeMath for uint256;

    uint256  public tokenSupply = 1000000000; 
            
    //This notifies clients about the number of tokens minted        
    event TokensMinted(address owner,uint256 value);

    // This notifies clients about the amount burnt , only admin is able to burn the contract
    event Burn(address from, uint256 value); 
    
    /* This is the main Token Constructor 
     */
	constructor() 

	ERC20 (tokenSupply,"Harambee","HRBE") public
    {
		owner = msg.sender;
	}
          
    /* This function is used to mint additional tokens
     * only admin can invoke this function
     * @param _mintedAmount amount of tokens to be minted  
     */
    function mintTokens(uint256 _mintedAmount) public onlyOwner {
        balanceOf[owner] = balanceOf[owner].add(_mintedAmount);
        totalSupply = totalSupply.add(_mintedAmount);
        emit TokensMinted(owner,_mintedAmount);      
    }    

    /**
    * This function Burns a specific amount of tokens.
    * @param _value The amount of token to be burned.
    */
    function burn(uint256 _value) public onlyOwner {
      require(_value <= balanceOf[msg.sender]);
      // no need to require value <= totalSupply, since that would imply the
      // sender's balance is greater than the totalSupply, which *should* be an assertion failure
      address burner = msg.sender;
      balanceOf[burner] = balanceOf[burner].sub(_value);
      totalSupply = totalSupply.sub(_value);
      emit Burn(burner, _value);
  }

    /**
     * This function is used to destroy the contract
     */
    function destroyContract() public onlyOwner{
        selfdestruct(owner);
    }
}
