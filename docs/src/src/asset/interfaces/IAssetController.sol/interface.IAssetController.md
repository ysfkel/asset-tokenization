# IAssetController
[Git Source](https://gitlab.com/paper-tale-digital/blockchain/blob/3aef46fe69e8a41cefa0ac9d66abcd9403a5af24/src/asset/interfaces/IAssetController.sol)

**Author:**
Yusuf

Defines interface for asset mint and consume functionlaity.


## Functions
### mint

mints new asset

*contentIds are previously minted assets which are consumed to mint new asset
each contentId must have its amount in amounts*


```solidity
function mint(
    uint256 amount,
    bytes32 name,
    bytes32 symbol,
    uint256[] calldata contentIds,
    uint256[] calldata amounts,
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


