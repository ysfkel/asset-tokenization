# Payroll
[Git Source](https://gitlab.com/paper-tale-digital/blockchain/blob/3aef46fe69e8a41cefa0ac9d66abcd9403a5af24/src/payroll/Payroll.sol)

**Inherits:**
Initializable, AccessControlUpgradeable, [IPayroll](/src/payroll/interfaces/IPayroll.sol/interface.IPayroll.md)

**Author:**
Yusuf

This is a upgradeable smart contract and implements Initializable
ensure to execute the initialize function after contract deployment to prevent thrid party from executing this and taking ownersip of the smart contract


## State Variables
### OWNER_ROLE

```solidity
bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");
```


### READ_ROLE

```solidity
bytes32 public constant READ_ROLE = keccak256("READ_ROLE");
```


### DEFAULT_READ_ROLE

```solidity
bytes32 public constant DEFAULT_READ_ROLE = keccak256("DEFAULT_READ_ROLE");
```


### ids

```solidity
bytes32[] private ids;
```


### payrolDataReferences

```solidity
bytes32[] private payrolDataReferences;
```


### payrolls

```solidity
mapping(bytes32 => P.PayrollData) private payrolls;
```


## Functions
### onlyAdmin


```solidity
modifier onlyAdmin();
```

### onlyOwner


```solidity
modifier onlyOwner();
```

### onlyReadRole


```solidity
modifier onlyReadRole();
```

### initialize

initializes the contracts . Must be called after proxy creation


```solidity
function initialize() external initializer;
```

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
) external onlyOwner;
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
    bytes32 payrolDataReference
) external onlyOwner;
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
|`payrolDataReference`|`bytes32`||


### addDatareference

adds dataref to existing payroll


```solidity
function addDatareference(bytes32 id, bytes32 dataReference) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`id`|`bytes32`|payroll id|
|`dataReference`|`bytes32`|payroll data reference|


### closePayroll

closes an active payroll by setting its status to closed


```solidity
function closePayroll(bytes32 id) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`id`|`bytes32`|id of the payrol to close|


### addDataReferenceAndClosePayroll

Adds data reference to existing payroll and closes the payroll


```solidity
function addDataReferenceAndClosePayroll(bytes32 id, bytes32 dataReference) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`id`|`bytes32`|payrol id|
|`dataReference`|`bytes32`|payrol data reference|


### grantAdminRole

grants admin role to account


```solidity
function grantAdminRole(address account) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|to be granted admin role|


### revokeAdminRole

revokes admin role from account


```solidity
function revokeAdminRole(address account) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|to be revoked|


### grantOwnerRole

grants owner role to account


```solidity
function grantOwnerRole(address account) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|to be granted admin role|


### revokeOwnerRole

revokes owner role from account


```solidity
function revokeOwnerRole(address account) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|to be revoked|


### grantReadRole

grants read role to account


```solidity
function grantReadRole(address account) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|to be granted read role|


### revokeReadRole

revokes read role from account


```solidity
function revokeReadRole(address account) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|to be revoked|


### grantRole

grants role to specified account

*overrides the modifier*


```solidity
function grantRole(bytes32 role, address account) public virtual override onlyAdmin;
```

### revokeRole

revokes role from specified account except DEFAULT_READ_ROLE

*overrides the modifier*


```solidity
function revokeRole(bytes32 role, address account) public virtual override onlyAdmin;
```

### getPayroll

returns the invoice data


```solidity
function getPayroll(bytes32 id) external view onlyReadRole returns (P.PayrollData memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`id`|`bytes32`|identifier of the invoice|


### getPayrollIds

returns the list of payroll ids


```solidity
function getPayrollIds() external view onlyReadRole returns (bytes32[] memory);
```

### getPayrollDataReferences

returns the list of payroll Data Identifiers


```solidity
function getPayrollDataReferences() external view onlyReadRole returns (bytes32[] memory);
```

### _addPayroll

private function _addPayroll. completes addPayroll external function


```solidity
function _addPayroll(
    uint256 startDate,
    uint256 endDate,
    uint256 revision,
    bytes32 name,
    bytes32 payrollType,
    bytes32 id,
    bytes32 dataReference
) private;
```

### _addDatareference

private function _addDatareference. completes addDatareference external function


```solidity
function _addDatareference(bytes32 id, bytes32 dataReference) private;
```

### _closePayroll

private function _closePayroll. completes closePayroll external function


```solidity
function _closePayroll(bytes32 id) private;
```

## Events
### PayrollAdded

```solidity
event PayrollAdded(bytes32 indexed id, uint256 publishDate);
```

### PayrollClosed

```solidity
event PayrollClosed(bytes32 indexed id);
```

### DataReferenceAdded

```solidity
event DataReferenceAdded();
```

## Errors
### Payroll__AlreadyExists

```solidity
error Payroll__AlreadyExists();
```

### Payroll__NotFound

```solidity
error Payroll__NotFound();
```

### Payroll__InvalidID

```solidity
error Payroll__InvalidID();
```

### Payroll__DataReferenceMustNotBeEmpty

```solidity
error Payroll__DataReferenceMustNotBeEmpty();
```

### Payroll__AlreadyClosed

```solidity
error Payroll__AlreadyClosed();
```

### Payroll__DefaultReadRoleCannotBeRevoked

```solidity
error Payroll__DefaultReadRoleCannotBeRevoked();
```

### Payroll__AccessControl__CallerIsNotAdminRole

```solidity
error Payroll__AccessControl__CallerIsNotAdminRole(address caller);
```

### Payroll__AccessControl__CallerIsNotOwnerRole

```solidity
error Payroll__AccessControl__CallerIsNotOwnerRole(address caller);
```

### Payroll__AccessControl__CallerIsNotReadRole

```solidity
error Payroll__AccessControl__CallerIsNotReadRole(address caller);
```

