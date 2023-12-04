# AssetController
[Git Source](https://gitlab.com/paper-tale-digital/blockchain/blob/3aef46fe69e8a41cefa0ac9d66abcd9403a5af24/src/asset/AssetController.sol)

**Inherits:**
[IAssetController](/src/asset/interfaces/IAssetController.sol/interface.IAssetController.md), IERC1155ReceiverUpgradeable, OwnableUpgradeable, UUPSUpgradeable

**Author:**
Yusuf

Implements AssetController
This contract inherits UUPS (Universal Upgradeable Proxy Standard)
ensure to execute the initialize function after contract deployment
to prevent thrid party from executing this and taking ownersip of the smart contract


## State Variables
### assetCount

```solidity
uint256 public assetCount;
```


### maxContentPerTransaction

```solidity
uint256 public maxContentPerTransaction;
```


### assets

```solidity
Asset public assets;
```


### _assetCreator

```solidity
mapping(uint256 assetId => address owner) private _assetCreator;
```


### _assetContent

```solidity
mapping(uint256 assetId => uint256[] contentIds) private _assetContent;
```


### _assetContentAmount

```solidity
mapping(uint256 assetId => mapping(uint256 contentId => uint256 amount)) private _assetContentAmount;
```


## Functions
### initialize


```solidity
function initialize(address assetToken, uint256 _maxContentPerTransaction) external initializer;
```

### mint

mints new asset

*contentIds are previously minted assets which are consumed to mint new asset
each contentId must have its amount in amounts*


```solidity
function mint(
    uint256 amount,
    bytes32 name,
    bytes32 symbol,
    uint256[] memory contentIds,
    uint256[] memory amounts,
    bytes memory data
) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|Amount of asset to mint|
|`name`|`bytes32`|Name of asset|
|`symbol`|`bytes32`|Asset symbol|
|`contentIds`|`uint256[]`|assets to consume / lock inorder to mint new asset|
|`amounts`|`uint256[]`|amounts of contentIds to consume|
|`data`|`bytes`|refer - ERC1155 _mint|


### consume

consumes contents to assetId


```solidity
function consume(uint256 assetId, uint256[] memory contentIds, uint256[] memory amounts, bytes memory data) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`assetId`|`uint256`|Id of asset to add contents to|
|`contentIds`|`uint256[]`|Id's of assets which will be consumed|
|`amounts`|`uint256[]`|amounts of contentIds|
|`data`|`bytes`|- refer - ERC1155 _mint|


### transfer

transfers assets from sender to `to` address


```solidity
function transfer(address to, uint256 id, uint256 amount, bytes memory data) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`to`|`address`|receiver address|
|`id`|`uint256`|Id of asset to transfer|
|`amount`|`uint256`|Amount to transfer|
|`data`|`bytes`|refer - ERC1155 _mint|


### batchTransferFrom

batch transfer from sender to receiver `to` address


```solidity
function batchTransferFrom(address to, uint256[] memory assetIds, uint256[] memory amounts, bytes memory data)
    external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`to`|`address`|receiver address|
|`assetIds`|`uint256[]`|assets to transfer|
|`amounts`|`uint256[]`|amounts of assets to transfer|
|`data`|`bytes`|refer - ERC1155 _mint|


### onERC1155Received


```solidity
function onERC1155Received(address, address, uint256, uint256, bytes calldata) external pure returns (bytes4);
```

### onERC1155BatchReceived


```solidity
function onERC1155BatchReceived(address, address, uint256[] calldata, uint256[] calldata, bytes calldata)
    external
    pure
    returns (bytes4);
```

### assetExists

checks if assetId exists in memory


```solidity
function assetExists(uint256 assetId) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`assetId`|`uint256`|assetId to check|


### getAssetContent

*contents are assetIds whhich where consumed to mint assetId*


```solidity
function getAssetContent(uint256 assetId) external view returns (uint256[] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`assetId`|`uint256`|AssetId to retrive its contents|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256[]`|returns contents of assetId|


### getAssetContentAmount


```solidity
function getAssetContentAmount(uint256 assetId, uint256 contentId) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`assetId`|`uint256`|assetid|
|`contentId`|`uint256`|contentid|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|returns the amount of contentId|


### supportsInterface


```solidity
function supportsInterface(bytes4 interfaceId) external pure returns (bool);
```

### _authorizeUpgrade


```solidity
function _authorizeUpgrade(address newImplementation) internal override onlyOwner;
```

### _consume


```solidity
function _consume(uint256 assetId, uint256[] memory contentIds, uint256[] memory amounts, bytes memory data) private;
```

### _mint


```solidity
function _mint(uint256 id, uint256 amount, bytes32 name, bytes32 symbol, bytes memory data) private;
```

## Events
### BatchTransfer

```solidity
event BatchTransfer(address indexed from, address indexed to, uint256[] assetIds, uint256[] amounts);
```

### Transfer

```solidity
event Transfer(address indexed from, address indexed to, uint256 indexed assetId, uint256 amount);
```

### Consume

```solidity
event Consume(address indexed sender, uint256 indexed assetId, uint256[] contentIds, uint256[] amounts);
```

### Mint

```solidity
event Mint(address indexed sender, uint256 indexed assetId, uint256 amount, uint256[] contentIds, uint256[] amounts);
```

## Errors
### AssetController__NotAssetOwner

```solidity
error AssetController__NotAssetOwner();
```

### AssetController__ZeroAddress

```solidity
error AssetController__ZeroAddress();
```

### AssetController__ZeroAmount

```solidity
error AssetController__ZeroAmount();
```

### AssetController__CannotConsumeToZeroAssetBalance

```solidity
error AssetController__CannotConsumeToZeroAssetBalance();
```

### AssetController__UnknownAsset

```solidity
error AssetController__UnknownAsset(uint256 assetId);
```

### AssetController__InsufficientAssetBalance

```solidity
error AssetController__InsufficientAssetBalance(address sender, uint256 assetId);
```

### AssetController__ContentIdsAmountsMismatch

```solidity
error AssetController__ContentIdsAmountsMismatch(uint256 assetIdsLength, uint256 amountsLength);
```

### AssetController__ExceededMaxContentPerTransaction

```solidity
error AssetController__ExceededMaxContentPerTransaction();
```

