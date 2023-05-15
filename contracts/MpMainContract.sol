//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./GlobalVariables.sol";
import "./VaultManagers.sol";
import "./UserDeposit.sol";
import "./UserWithdrawal.sol";
import "./Escapes.sol";
import "./StateRoot.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract MpMainContract is
  GlobalVariables,
  VaultManagers,
  UserDeposit,
  UserWithdrawal,
  Escapes,
  StateRoot,
  Initializable
{
  function initialize() public initializer{
    sequenceNumber = 0;
    updateTimestamp = 0;
    stateFrozen = false;
    vaultOwner = msg.sender;
    vaultManagers[msg.sender] = true;
  }
  
  //fallback functions
  receive() external payable {}
  fallback() external payable {}
}