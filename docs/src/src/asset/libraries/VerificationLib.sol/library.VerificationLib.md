# VerificationLib
[Git Source](https://gitlab.com/paper-tale-digital/blockchain/blob/3aef46fe69e8a41cefa0ac9d66abcd9403a5af24/src/asset/libraries/VerificationLib.sol)


## Functions
### get


```solidity
function get(Verifications storage map, address key) public view returns (DataTypes.Verification memory);
```

### getKeyAtIndex


```solidity
function getKeyAtIndex(Verifications storage map, uint256 index) public view returns (address);
```

### size


```solidity
function size(Verifications storage map) public view returns (uint256);
```

### set


```solidity
function set(Verifications storage map, address key, DataTypes.Verification memory val) public;
```

### remove


```solidity
function remove(Verifications storage map, address key) public;
```

## Structs
### Verifications

```solidity
struct Verifications {
    address[] keys;
    mapping(address => DataTypes.Verification) values;
    mapping(address => uint256) indexOf;
    mapping(address => bool) inserted;
}
```

