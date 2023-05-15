//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./GlobalVariables.sol";
import "./UserWithdrawal.sol";
import "./Freezable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/MerkleProofUpgradeable.sol";

abstract contract Escapes is GlobalVariables, Freezable, UserWithdrawal {
  //events
  event DepositCancel(
    address indexed userAddress,
    address tokenAddress
  );

  event DepositReclaim(
    address indexed userAddress,
    address indexed tokenAddress,
    uint256 amount
  );

  event ContractFrozen(
    address userAddress,
    uint256 timestamp
  );

  //view functions
  function getDepositCancellationTimestamp(address userAddress, address tokenAddress) public view returns (uint256) {
    return depositCancellation[userAddress][tokenAddress];
  }

  function isClaimedUsers(address userAddress) public view returns(bool){
    return claimedUsers[userAddress];
  }

  //Escape hatch - deposit flow
  function depositCancel(address tokenAddress) external {
    //make sure user has pending deposit
    require(pendingDeposit[msg.sender][tokenAddress] > 0, "No pending deposit found");
    //record cancellation time
    depositCancellation[msg.sender][tokenAddress] = block.timestamp;
    emit DepositCancel(msg.sender, tokenAddress);
  }

  function depositReclaim(address tokenAddress) external payable{
    //make sure sufficient time has passed
    uint256 _requestTime = depositCancellation[msg.sender][tokenAddress];
    require(_requestTime != 0, "Deposit not cancelled");
    uint256 _releaseTime = _requestTime + DEPOSIT_CANCEL_DELAY;
    require(block.timestamp > _releaseTime, "Deposit still locked");
    //clear pendingDeposit and depositCancellation records
    uint256 amountToTransfer = pendingDeposit[msg.sender][tokenAddress];
    delete pendingDeposit[msg.sender][tokenAddress];
    delete depositCancellation[msg.sender][tokenAddress];
    //transfer the tokens back to msg.sender
    bool transferred = withdrawInternal(tokenAddress, amountToTransfer);
    require(transferred, "Deposit not reclaimed");
    emit DepositReclaim(msg.sender, tokenAddress, amountToTransfer);
  }

  //Escape hatch - withdraw flow
  function requestForcedWithdrawal() external notFrozen {
    //user should only perform a forced withdrawal if the state root last update time exceeds
    //the MAX_STATE_ROOT_UPDATE_TOLERANCE.
    require(block.timestamp > updateTimestamp + MAX_STATE_ROOT_UPDATE_TOLERANCE, "Max tolerance not breached");
    freeze();
    emit ContractFrozen(msg.sender, block.timestamp);
  }

  function forcedWithdrawal(bytes32[] calldata subRootProof, bytes32[] calldata merkleRootProof, bytes32 subRoot, address tokenAddress, uint256 amount) external payable onlyFrozen {
    require(!claimedUsers[msg.sender], "User submitted claimed already");
    //verify the subroot first
    bool subRootVerified = verifySubRootProof(subRootProof, subRoot, amount);
    require(subRootVerified, "SubRoot proof cannot be verified");
    //verify the merkle proof
    bool merkleRootVerified = verifyMerkleProof(merkleRootProof, subRoot, tokenAddress);
    require(merkleRootVerified, "Merkle root cannot be verified");
    //add user to the claimed user list
    claimedUsers[msg.sender] = true;
    //proved that the amount belongs to user, proceed to withdrawal
    bool withdrawn = withdrawInternal(tokenAddress, amount);
    require(withdrawn, "Withdrawal failed");
    emit Withdraw(msg.sender, tokenAddress, amount);
  }

  function verifyMerkleProof(bytes32[] calldata _proof, bytes32 _subRoot, address tokenAddress) internal view returns(bool){
    bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(tokenAddress, _subRoot))));
    return MerkleProofUpgradeable.verifyCalldata(_proof, stateRoot, leaf);
  }

  function verifySubRootProof(bytes32[] calldata _proof, bytes32 _subRoot, uint256 _amount) internal view returns(bool){
    bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(msg.sender, _amount))));
    return MerkleProofUpgradeable.verifyCalldata(_proof, _subRoot, leaf);
  }
}