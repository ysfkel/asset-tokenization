# DataTypes
[Git Source](https://gitlab.com/paper-tale-digital/blockchain/blob/3aef46fe69e8a41cefa0ac9d66abcd9403a5af24/src/asset/libraries/DataTypes.sol)


## Structs
### Document

```solidity
struct Document {
    uint256 date;
    bytes32 name;
    bytes32 location;
    address publisher;
}
```

### Verification

```solidity
struct Verification {
    bool verified;
    uint256 date;
    uint256 documentId;
    address verifier;
}
```

