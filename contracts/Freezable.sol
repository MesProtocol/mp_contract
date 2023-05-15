//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./GlobalVariables.sol";
import "./VaultManagers.sol";

abstract contract Freezable is GlobalVariables, VaultManagers {
  //modifiers
  modifier notFrozen {
    require(!stateFrozen, "Contract is frozen");
    _;
  }

  modifier onlyFrozen {
    require(stateFrozen, "Contract is not frozen");
    _;
  }
  //view functions
  function isFrozen() public view returns (bool){
    return stateFrozen;
  }

  //main freeze/unfreeze functions
  function freeze() internal notFrozen {
    unfreezeTime = block.timestamp + UNFREEZE_DELAY;
    stateFrozen = true;
  }

  function unfreeze() external onlyFrozen onlyVaultManager {
    require(block.timestamp >= unfreezeTime, "Unfreeze not allowed yet");
    stateFrozen = false;
  }
}