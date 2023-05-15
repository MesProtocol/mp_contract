//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./GlobalVariables.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

using SafeERC20 for IERC20;

abstract contract UserWithdrawal is GlobalVariables {
  //events
  event Withdraw(
    address indexed userAddress,
    address indexed tokenAddress,
    uint256 amount
  );

  //view functions
  function getPendingWithdrawal(address userAddress, address tokenAddress) public view returns (uint256){
    return pendingWithdrawal[userAddress][tokenAddress];
  }

  function getTotalPendingWithdrawal(address tokenAddress) public view returns (uint256){
    return totalPendingWithdrawal[tokenAddress];
  }

  //main withdrawal function
  function withdraw(address tokenAddress, uint256 amount) external payable{
    require(amount > 0, "Withdrawal amount must be larger than 0");
    //find user's pending withdrawal
    uint256 amountForWithdrawal = pendingWithdrawal[msg.sender][tokenAddress];
    require(amountForWithdrawal >= amount, "Insufficient balance to withdraw");
    //update pendingWithdrawal and total pending withdrawal records 
    pendingWithdrawal[msg.sender][tokenAddress] -= amount;
    totalPendingWithdrawal[tokenAddress] -= amount;
    //transfer funds
    bool withdrawn = withdrawInternal(tokenAddress, amount);
    require(withdrawn, 'Withdrawal failed');
    emit Withdraw(msg.sender, tokenAddress, amount);
  }

  function withdrawInternal(address _tokenAddress, uint256 _amount) internal returns(bool){
    if(_tokenAddress == 0x0000000000000000000000000000000000000000){
      //It is recommended to use .call to transfer ether
      (bool transferred, ) = payable(msg.sender).call{value: _amount}("");
      require(transferred, 'Failed to withdraw asset - ETH');
    }else{
      bool transferred = ERC20(_tokenAddress).transfer(msg.sender, _amount);
      require(transferred, 'Failed to withdraw asset');
    }
    return true;
  }

  function safeWithdraw(address tokenAddress, uint256 amount) external payable{
    require(amount > 0, "Withdrawal amount must be larger than 0");
    //find user's pending withdrawal
    uint256 amountForWithdrawal = pendingWithdrawal[msg.sender][tokenAddress];
    require(amountForWithdrawal >= amount, "Insufficient balance to withdraw");
    //update pendingWithdrawal and total pending withdrawal records 
    pendingWithdrawal[msg.sender][tokenAddress] -= amount;
    totalPendingWithdrawal[tokenAddress] -= amount;
    //transfer funds
    safeWithdrawInternal(tokenAddress, amount);
    emit Withdraw(msg.sender, tokenAddress, amount);
  }

  function safeWithdrawInternal(address _tokenAddress, uint256 _amount) internal {
    if(_tokenAddress == 0x0000000000000000000000000000000000000000){
      //It is recommended to use .call to transfer ether
      (bool transferred, ) = payable(msg.sender).call{value: _amount}("");
      require(transferred, 'Failed to withdraw asset - ETH');
    }else{
      //check allowance
      uint256 allowance = IERC20(_tokenAddress).allowance(address(this), address(this));
      if(allowance <= _amount){
        //insufficient allowance
        IERC20(_tokenAddress).safeApprove(address(this), 0);
        IERC20(_tokenAddress).safeApprove(address(this), type(uint256).max);
      }
      IERC20(_tokenAddress).safeTransferFrom(address(this), msg.sender, _amount);
    }
  }
}