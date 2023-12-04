# PayrollFactory
[Git Source](https://gitlab.com/paper-tale-digital/blockchain/blob/3aef46fe69e8a41cefa0ac9d66abcd9403a5af24/src/payroll/PayrollFactory.sol)

**Inherits:**
[IPayrollFactory](/src/payroll/interfaces/IPayrollFactory.sol/interface.IPayrollFactory.md), Ownable

**Author:**
Yusuf

deploys instances of Payroll contract


## State Variables
### payrollBeacon

```solidity
address public payrollBeacon;
```


### payrolls

```solidity
mapping(address => address[]) public payrolls;
```


## Functions
### constructor


```solidity
constructor(address _payrollBeacon) Ownable;
```

### createPayroll

This function should only be called by owner of the factory contract (paper tail). deploys payroll proxy and transfers ownership to payrollOwner


```solidity
function createPayroll(address owner, address admin) external onlyOwner returns (address payrollAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`owner`|`address`|address of the owner|
|`admin`|`address`|address of administrator|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`payrollAddress`|`address`|the address of the deployed payrol proxy|


### setBeacon

sets address of the beacon contract for the proxy


```solidity
function setBeacon(address newPayrollBeaconAddress) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newPayrollBeaconAddress`|`address`|beacon contract address|


### getPayrollList

returns list of payroll proxy address  for the specified address


```solidity
function getPayrollList(address payrollOwner) external view returns (address[] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`payrollOwner`|`address`|address of payrolls owner|


### _createPayroll


```solidity
function _createPayroll(address owner, address admin) private returns (address payrollAddress);
```

## Events
### PayrollCreated

```solidity
event PayrollCreated(address indexed payrollAddress);
```

### PayrollBeaconAddressUpdated

```solidity
event PayrollBeaconAddressUpdated(address newPayrollBeaconAddress);
```

## Errors
### PayrollFactory__NotContractAddress

```solidity
error PayrollFactory__NotContractAddress();
```

### PayrollFactory__ZeroAddress

```solidity
error PayrollFactory__ZeroAddress(address account);
```

