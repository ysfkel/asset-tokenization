# IAsset
[Git Source](https://gitlab.com/paper-tale-digital/blockchain/blob/3aef46fe69e8a41cefa0ac9d66abcd9403a5af24/src/asset/interfaces/IAsset.sol)

**Author:**
Yusuf

Defines interface for Asset.


## Functions
### mint


```solidity
function mint(address to, uint256 id, uint256 amount, bytes32 name, bytes32 symbol, bytes calldata data) external;
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


