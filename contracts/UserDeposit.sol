//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./GlobalVariables.sol";
import "./Freezable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

using SafeERC20 for IERC20;

abstract contract UserDeposit is GlobalVariables, Freezable {
  //events
  event Deposit(
    address indexed userAddress,
    address indexed tokenAddress,
    uint256 amount
  );

  //view functions
  function getPendingDeposit(address userAddress, address tokenAddress) public view returns (uint256){
    return pendingDeposit[userAddress][tokenAddress];
  }

  function getTotalPendingDeposit(address tokenAddress) public view returns (uint256){
    return totalPendingDeposit[tokenAddress];
  }

  //main deposit function
  function deposit(address tokenAddress, uint256 amount) external payable notFrozen{
    if(tokenAddress == 0x0000000000000000000000000000000000000000){
      require(msg.value > 0, "Deposit amount must be larger than 0");
      //add to pendingDeposit array and total pending deposit amount
      pendingDeposit[msg.sender][tokenAddress] += msg.value;
      totalPendingDeposit[tokenAddress] += msg.value;
      emit Deposit(msg.sender, tokenAddress, msg.value);
    }else{
      require(amount > 0, "Deposit amount must be larger than 0");
      bool tokenTransferred = ERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);
      require(tokenTransferred, "Failed to transfer tokens");
      //add to pendingDeposit array and total pending deposit amount
      pendingDeposit[msg.sender][tokenAddress] += amount;
      totalPendingDeposit[tokenAddress] += amount;
      emit Deposit(msg.sender, tokenAddress, amount);
    }
  }

  function safeDeposit(address tokenAddress, uint256 amount) external payable notFrozen{
    if(tokenAddress == 0x0000000000000000000000000000000000000000){
      require(msg.value > 0, "Deposit amount must be larger than 0");
      //add to pendingDeposit array and total pending deposit amount
      pendingDeposit[msg.sender][tokenAddress] += msg.value;
      totalPendingDeposit[tokenAddress] += msg.value;
      emit Deposit(msg.sender, tokenAddress, msg.value);
    }else{
      require(amount > 0, "Deposit amount must be larger than 0");
      IERC20(tokenAddress).safeTransferFrom(msg.sender, address(this), amount);
      //add to pendingDeposit array and total pending deposit amount
      pendingDeposit[msg.sender][tokenAddress] += amount;
      totalPendingDeposit[tokenAddress] += amount;
      emit Deposit(msg.sender, tokenAddress, amount);
    }
  }
}