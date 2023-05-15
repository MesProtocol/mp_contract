//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./GlobalVariables.sol";
import "./Freezable.sol";
import "./VaultManagers.sol";

abstract contract StateRoot is GlobalVariables, VaultManagers, Freezable {
  //structs
  struct MerkleTreeData {
    bytes32 oldMerkleRoot;
    bytes32 newMerkleRoot;
  }

  //events
  event UpdateMerkleRoot(
    uint256 indexed sequenceNumber,
    bytes32 currentMerkleRoot,
    uint256 updateTimestamp
  );

  //view functions
  function getSequenceNumber() public view returns (uint256) { 
    return sequenceNumber;
  }

  function getMerkleRoot() public view returns (bytes32) {
    return stateRoot;
  }

  function getUpdateTimestamp() public view returns (uint256) {
    return updateTimestamp;
  }

  //main update merkle root function
  function updateMerkleRoot(bytes32 oldMerkleRoot, bytes32 newMerkleRoot, uint256 newSequenceNumber) external notFrozen onlyVaultManager {
    //check if the old merkle root record matches
    require(oldMerkleRoot == stateRoot, "Merkle root record not match");
    //check if the new sequence number is larger than current
    require(newSequenceNumber > sequenceNumber, "Cannot backdate to previous merkle root");
    //update merkle root, sequence number and update timestamp
    stateRoot = newMerkleRoot;
    sequenceNumber = newSequenceNumber;
    updateTimestamp = block.timestamp;
    emit UpdateMerkleRoot(newSequenceNumber, stateRoot, updateTimestamp);
  }
}