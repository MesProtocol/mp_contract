//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
/*
Holds ALL the main contract state (storage) variables.
*/
contract GlobalVariables {
  //vault managers/operator list 
  mapping(address => bool) vaultManagers;
  //vault owner address
  address vaultOwner;
  //state root's sequence number, has to be consistent across rollups
  uint256 sequenceNumber;
  //state root's last update timestamp
  uint256 updateTimestamp;
  //state root for all balances across rollups
  bytes32 stateRoot;
  //contract state, user can request to freeze contract if state root is not updated for a period of time
  bool stateFrozen;
  //in case contract is frozen, user has a grace period till unfreeze time to withdraw money from the exchange
  uint256 unfreezeTime;
  //pending deposit/withdrawal map: user address => token address => amount.
  mapping(address => mapping(address => uint256)) pendingDeposit;
  mapping(address => mapping(address => uint256)) pendingWithdrawal;
  mapping(address => uint256) totalPendingDeposit;
  mapping(address => uint256) totalPendingWithdrawal;
  //deposit cancel: user address => token address => cancel block timestamp
  mapping(address => mapping(address => uint256)) depositCancellation;
  //list of users claimed the full amounts from the contract when it is freezed
  mapping(address => bool) claimedUsers;
  //constants
  uint256 constant DEPOSIT_CANCEL_DELAY = 1 days;
  uint256 constant MAX_STATE_ROOT_UPDATE_TOLERANCE = 5 days;
  uint256 constant UNFREEZE_DELAY = 30 days;
  //storage gap
  uint256[50] __gap; 
}