# IPayroll
[Git Source](https://gitlab.com/paper-tale-digital/blockchain/blob/3aef46fe69e8a41cefa0ac9d66abcd9403a5af24/src/payroll/interfaces/IPayroll.sol)

**Author:**
Yusuf

specification for Payrol funtionality


## Functions
### addPayrollAndClosePayroll

adds new invoice and closes the invoice


```solidity
function addPayrollAndClosePayroll(
    uint256 startDate,
    uint256 endDate,
    uint256 revision,
    bytes32 name,
    bytes32 payrollType,
    bytes32 id,
    bytes32 dataReference
) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`startDate`|`uint256`|start date of invoice|
|`endDate`|`uint256`|end date of invoice|
|`revision`|`uint256`|revision of the payroll|
|`name`|`bytes32`|payroll name|
|`payrollType`|`bytes32`|payrollType|
|`id`|`bytes32`|identifier of the invoice - decentralized storage identifier of the invoice|
|`dataReference`|`bytes32`|payrol json data reference|


### addPayroll

adds new invoice


```solidity
function addPayroll(
    uint256 startDate,
    uint256 endDate,
    uint256 revision,
    bytes32 name,
    bytes32 payrollType,
    bytes32 id,
    bytes32 dataReference
) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`startDate`|`uint256`|start date of invoice|
|`endDate`|`uint256`|end date of invoice|
|`revision`|`uint256`|revision of the payroll|
|`name`|`bytes32`|payroll name|
|`payrollType`|`bytes32`|payrollType|
|`id`|`bytes32`|identifier of the invoice - decentralized storage identifier of the invoice|
|`dataReference`|`bytes32`|payrol json data idenfier|


### addDatareference

adds dataref to existing payroll


```solidity
function addDatareference(bytes32 id, bytes32 dataReference) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`id`|`bytes32`|payroll id|
|`dataReference`|`bytes32`|payroll data reference|


### addDataReferenceAndClosePayroll

Adds data reference to existing payroll and closes the payroll


```solidity
function addDataReferenceAndClosePayroll(bytes32 id, bytes32 dataReference) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`id`|`bytes32`|payrol id|
|`dataReference`|`bytes32`|payrol data reference|


### closePayroll

closes an active payroll by setting its status to closed


```solidity
function closePayroll(bytes32 id) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`id`|`bytes32`|id of the payrol to close|


### grantAdminRole

grants admin role to account


```solidity
function grantAdminRole(address account) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|to be granted admin role|


### revokeAdminRole

revokes admin role from account


```solidity
function revokeAdminRole(address account) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|to be revoked|


### grantOwnerRole

grants owner role to account


```solidity
function grantOwnerRole(address account) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|to be granted admin role|


### revokeOwnerRole

revokes owner role from account


```solidity
function revokeOwnerRole(address account) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|to be revoked|


### grantReadRole

grants read role to account


```solidity
function grantReadRole(address account) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|to be granted read role|


### revokeReadRole

revokes read role from account


```solidity
function revokeReadRole(address account) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|to be revoked|


### getPayroll

returns the invoice data


```solidity
function getPayroll(bytes32 id) external view returns (P.PayrollData memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`id`|`bytes32`|identifier of the invoice|


### getPayrollIds

returns the list of payroll ids


```solidity
function getPayrollIds() external view returns (bytes32[] memory);
```

### getPayrollDataReferences

returns the list of payroll Data Identifiers


```solidity
function getPayrollDataReferences() external view returns (bytes32[] memory);
```

