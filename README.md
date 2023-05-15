# MES Protocol - Decentralized Exchange (DEX)

MES Protocol is a next-generation Decentralized Exchange (DEX) that leverages the power of blockchain technology to provide a secure, scalable, and efficient trading platform for cryptocurrencies.

## Features

- Adopting the Validium model for enhanced security and scalability
- Smart contract broken down into three main sections: User Deposit/Withdrawal, Operator functions, and Escape Hatches

### Validium Model

MES Protocol adopts the Validium model, which combines the best of both zk-rollup and zk-plasma models, offering increased security and scalability. The benefits of the Validium model include:

- Enhanced security: The model ensures that all transactions are batched and verified on-chain, providing a higher level of trust and security.
- Better scalability: By batching multiple transactions into a single proof, the model significantly reduces the on-chain data storage requirements, allowing the platform to scale efficiently.

### Smart Contract Sections

The MES Protocol smart contract is divided into three main sections:

1. **User Deposit/Withdrawal**: This section contains the main functions to handle user's deposit and withdrawal requests.
2. **Operator functions**: This section includes the main functions to accept/validate user's deposit and withdrawal requests.
3. **Escape Hatches**: This section incorporates the main functions to verify Merkle proofs and allow users to permissionlessly withdraw assets.

#### 1. User Deposit/Withdrawal

Within the User Deposit/Withdrawal section, users can perform the following actions:

- Deposit their assets into the protocol
- Request a withdrawal of their assets

#### 2. Operator Functions

The Operator functions section of the smart contract allows the operator to:

- Accept and validate user's deposit requests
- Accept and validate user's withdrawal requests

#### 3. Escape Hatches

The Escape Hatches section provides the following functionalities:

- Verify Merkle proofs to ensure the validity of user's deposits and withdrawals
- Allow users to permissionlessly withdraw their assets in case of operator misbehavior or unavailability

## Getting Started

To start using the MES Protocol, please follow the steps provided in the [Getting Started Guide](./docs/getting-started.md).

## License

MES Protocol is released under the [MIT License](./LICENSE).
