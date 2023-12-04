# PayrollProxy
[Git Source](https://gitlab.com/paper-tale-digital/blockchain/blob/3aef46fe69e8a41cefa0ac9d66abcd9403a5af24/src/payroll/PayrollProxy.sol)

**Inherits:**
BeaconProxy

**Author:**
Yusuf

Proxy for Payroll contract


## Functions
### constructor


```solidity
constructor(address _beacon) BeaconProxy(_beacon, "");
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_beacon`|`address`|Address of deployed Payrol beacon contract|


### getImplementation

returns the address of the Payrol implementation contract used by the proxy


```solidity
function getImplementation() external view returns (address);
```

### getBeacon

returns the address of the beacon contract


```solidity
function getBeacon() external view returns (address);
```

