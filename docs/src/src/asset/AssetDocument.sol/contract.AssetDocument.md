# AssetDocument
[Git Source](https://gitlab.com/paper-tale-digital/blockchain/blob/3aef46fe69e8a41cefa0ac9d66abcd9403a5af24/src/asset/AssetDocument.sol)

**Inherits:**
UUPSUpgradeable, OwnableUpgradeable


## State Variables
### controller

```solidity
IAssetController private controller;
```


### verifications

```solidity
mapping(bytes32 documentId => Verification[] verifications) private verifications;
```


### verifers

```solidity
mapping(bytes32 documentId => address[] verifiers) private verifers;
```


### assetDocumentIds

```solidity
mapping(uint256 assetid => bytes32[] documentId) assetDocumentIds;
```


### assetDocument

```solidity
mapping(uint256 assetid => mapping(bytes32 documentId => Document)) assetDocument;
```


### isVerifier

```solidity
mapping(address account => mapping(bytes32 document => bool allowed)) private isVerifier;
```


## Functions
### initialize


```solidity
function initialize(address _controller) external initializer;
```

### addDocument


```solidity
function addDocument(uint256 assetId, bytes32 documentId) external;
```

### _authorizeUpgrade


```solidity
function _authorizeUpgrade(address newImplementation) internal override onlyOwner;
```

## Errors
### AssetDocument__ZeroAddress

```solidity
error AssetDocument__ZeroAddress();
```

### AssetDocument__ZeroBytes32

```solidity
error AssetDocument__ZeroBytes32();
```

### AssetDocument_NoMatchingAsset

```solidity
error AssetDocument_NoMatchingAsset();
```

## Structs
### Verification

```solidity
struct Verification {
    address account;
    uint256 timestamp;
    bool verify;
}
```

### Document

```solidity
struct Document {
    uint256 assetId;
    address account;
    uint256 timestamp;
    bytes32 documentId;
}
```

