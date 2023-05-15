//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./GlobalVariables.sol";

abstract contract Ownable is GlobalVariables {
  modifier onlyOwner {
    require(msg.sender == vaultOwner, "Unauthorized");
    _;
  }
}