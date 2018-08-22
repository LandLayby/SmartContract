pragma solidity 0.4.24;

import "../Token/HarambeeToken.sol";
import "../Token/Owned.sol";
import "../Math/SafeMath.sol";


/**
 * @title TokenVesting
 * owner.
 */
contract TokenVesting is Owned {
  using SafeMath for uint256;
 
  event Released(uint256 amount);

  // beneficiary of tokens after they are released
  address public beneficiary;
  uint256 public start;
  uint256 public duration;
  uint256 public end;
  HarambeeToken public vestedtoken;
  uint256 public amountvested;



  /**
   * @dev Creates a vesting contract that vests its balance of Harambee token to the
   * _beneficiary, gradually in a linear fashion until _start + _duration. By then all
   * of the balance will have vested.
   */
  constructor(
    address _beneficiary,
    uint256 _start,
    uint256 _duration,   
    HarambeeToken _vestedtoken,
    uint256 _amounttobevested
  )
    public
  {
    require(_beneficiary != address(0));
    beneficiary = _beneficiary;
    duration = _duration;
    start = _start;
    end = _start + _duration;
    vestedtoken = _vestedtoken;
    amountvested = _amounttobevested;
  }

  /**
   * @notice Transfers vested tokens to beneficiary.
   */
  function release() public {  
    require(now >= duration);
    require(msg.sender == beneficiary);
    uint256 unreleased = vestedAmount();
    require(unreleased > 0);
    amountvested =  0;
    vestedtoken.transfer(beneficiary, unreleased);
    emit Released(unreleased);
  }

  /**
   * @dev returns the amount that has  vested.
   */
  function vestedAmount() public view returns (uint256) {
    return amountvested;
  }
}
