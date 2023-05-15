//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./GlobalVariables.sol";
import "./Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

using SafeERC20 for IERC20;

abstract contract VaultManagers is GlobalVariables, Ownable {
  //events
  event WithdrawAccept(
    address indexed userAddress,
    address indexed tokenAddress,
    uint256 amount
  );
  //modifiers
  modifier onlyVaultManager {
   require(vaultManagers[msg.sender], 'Unauthorized');
   _;
  }

  //view functions
  function isVaultManager(address addrToCheck) public view returns (bool){
    return vaultManagers[addrToCheck];
  }

  //register/remove vault manager functions
  function registerVaultManager(address addrToRegister) external onlyOwner {
    vaultManagers[addrToRegister] = true;
  }

  function removeVaultManager(address addrToRemove) external onlyOwner {
    vaultManagers[addrToRemove] = false;
  }

  //operator functions
  function depositAccept(address userAddress, address tokenAddress, uint256 amount) external onlyVaultManager {
    require(amount > 0, "No deposit amount given");
    require(pendingDeposit[userAddress][tokenAddress] >= amount, "Insufficient deposit to claim");
    pendingDeposit[userAddress][tokenAddress] -= amount;
    totalPendingDeposit[tokenAddress] -= amount;
  }

  function withdrawAccept(address userAddress, address tokenAddress, uint256 amount) external onlyVaultManager {
    require(amount > 0, "Withdrawal amount must be larger than 0");
    //transfer funds
    safeWithdrawAcceptInternal(userAddress, tokenAddress, amount);
    emit WithdrawAccept(msg.sender, tokenAddress, amount);
  }

  function safeWithdrawAcceptInternal(address _userAddress, address _tokenAddress, uint256 _amount) internal {
    if(_tokenAddress == 0x0000000000000000000000000000000000000000){
      //It is recommended to use .call to transfer ether
      (bool transferred, ) = payable(_userAddress).call{value: _amount}("");
      require(transferred, 'Failed to withdraw asset - ETH');
    }else{
      //check allowance of vault manager
      uint256 allowance = IERC20(_tokenAddress).allowance(address(this), msg.sender);
      if(allowance <= _amount){
        //insufficient allowance
        IERC20(_tokenAddress).safeApprove(msg.sender, 0);
        IERC20(_tokenAddress).safeApprove(msg.sender, type(uint256).max);
      }
      IERC20(_tokenAddress).safeTransferFrom(address(this), _userAddress, _amount);
    }
  }
}