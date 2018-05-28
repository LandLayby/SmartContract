pragma solidity ^0.4.21;

import "../Token/HarambeeToken.sol";
import "../Token/Owned.sol";
import "../Math/SafeMath.sol";


/**
 * @title TokenVesting
 * @dev A token holder contract that can release its token balance gradually like a
 * typical vesting scheme
 */
contract TokenVesting is Owned {
  using SafeMath for uint256;
  
  event Released(uint256 amount);
  event Revoked();

  // beneficiary of tokens after they are released
  address public beneficiary;

  uint256 public start;
  uint256 public duration;

  bool public revocable;

  mapping (address => uint256) public released;
  mapping (address => bool) public revoked;

  /**
   * @dev Creates a vesting contract that vests its balance of any HarambeeToken to the
   * _beneficiary, gradually in a linear fashion until _start + _duration. By then all
   * of the balance will have vested.
   * @param _beneficiary address of the beneficiary to whom vested tokens are transferred   
   * @param _duration duration in seconds of the period in which the tokens will vest
   * @param _revocable whether the vesting is revocable or not
   */
  function ApplyTokenVesting(
    address _beneficiary,
    uint256 _start,    
    uint256 _duration,
    bool _revocable
  )
    public
  {
    require(_beneficiary != address(0));    
    beneficiary = _beneficiary;
    revocable = _revocable;
    duration = _duration;    
    start = _start;
  }

  /**
   * @notice Transfers vested tokens to beneficiary.
   * @param token HarambeeToken  which is being vested
   */
  function release(HarambeeToken token) public {
    uint256 unreleased = releasableAmount(token);
    require(unreleased > 0);
    released[token] = released[token].add(unreleased);
    token.Transfer(beneficiary, unreleased);
    
    emit Released(unreleased);
  }

  /**
   * @notice Allows the owner to revoke the vesting. Tokens already vested
   * remain in the contract, the rest are returned to the owner.
   * @param token HarambeeToken which is being vested
   */
  function revoke(HarambeeToken token) public onlyOwner {
    require(revocable);
    require(!revoked[token]);
    uint256 balance = token.balanceOf(this);

    uint256 unreleased = releasableAmount(token);
    uint256 refund = balance.sub(unreleased);

    revoked[token] = true;
    token.safeTransfer(owner, refund);
    emit Revoked();
  }

  /**
   * @dev Calculates the amount that has already vested but hasn't been released yet.
   * @param token HarambeeToken which is being vested
   */
  function releasableAmount(HarambeeToken token) public view returns (uint256) {
    return vestedAmount(token).sub(released[token]);
  }

  /**
   * @dev Calculates the amount that has already vested.
   * @param token HarambeeToken which is being vested
   */
  function vestedAmount(HarambeeToken token) public view returns (uint256) {
    uint256 currentBalance = token.balanceOf(this);
    uint256 totalBalance = currentBalance.add(released[token]);

    if (block.timestamp >= start.add(duration) || revoked[token]) {
      return totalBalance;
    } else {
      return totalBalance.mul(block.timestamp.sub(start)).div(duration);
    }
  }
}