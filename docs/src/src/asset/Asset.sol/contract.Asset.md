# Asset
[Git Source](https://gitlab.com/paper-tale-digital/blockchain/blob/3aef46fe69e8a41cefa0ac9d66abcd9403a5af24/src/asset/Asset.sol)

**Inherits:**
[IAsset](/src/asset/interfaces/IAsset.sol/interface.IAsset.md), ERC1155, UUPSUpgradeable, OwnableUpgradeable

**Author:**
Yusuf

Implements IAsset.
This contract inherits UUPS (Universal Upgradeable Proxy Standard)
ensure to execute the initialize function after contract deployment
to prevent thrid party from executing this and taking ownersip of the smart contract


## State Variables
### _name

```solidity
mapping(uint256 assetId => bytes32 name) private _name;
```


### _symbol

```solidity
mapping(uint256 assetId => bytes32 symbol) private _symbol;
```


## Functions
### initialize


```solidity
function initialize(string memory tokenUri) external initializer;
```

### mint


```solidity
function mint(address to, uint256 id, uint256 amount, bytes32 name, bytes32 symbol, bytes memory data)
    external
    onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`to`|`address`|receiver address|
|`id`|`uint256`|asset id to mint|
|`amount`|`uint256`|asset amount to mint|
|`name`|`bytes32`|aasset name|
|`symbol`|`bytes32`|asset symbol|
|`data`|`bytes`|-refer ERC1155 _mint|


### nameOf


```solidity
function nameOf(uint256 id) external view returns (bytes32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`id`|`uint256`|asset id|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes32`|returns asset name in bytes32|


### symbolOf


```solidity
function symbolOf(uint256 id) external view returns (bytes32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`id`|`uint256`|asset id|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes32`|returns asset symbol in bytes32|


### safeTransferFrom


```solidity
function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data)
    public
    override
    onlyOwner;
```

### safeBatchTransferFrom


```solidity
function safeBatchTransferFrom(
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
) public override onlyOwner;
```

### _authorizeUpgrade


```solidity
function _authorizeUpgrade(address newImplementation) internal override onlyOwner;
```

### setApprovalForAll


```solidity
function setApprovalForAll(address owner, bool approved) public override onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`owner`|`address`|This is the asset owner|
|`approved`|`bool`|approves sender to control owner's assets|


## Errors
### Asset__CallerIsNotTokenOwner

```solidity
error Asset__CallerIsNotTokenOwner();
```

### Asset__CallerIsNotApprovedToTransfer

```solidity
error Asset__CallerIsNotApprovedToTransfer();
```

