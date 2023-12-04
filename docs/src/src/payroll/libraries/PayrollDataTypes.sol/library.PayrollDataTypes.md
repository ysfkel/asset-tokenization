# PayrollDataTypes
[Git Source](https://gitlab.com/paper-tale-digital/blockchain/blob/3aef46fe69e8a41cefa0ac9d66abcd9403a5af24/src/payroll/libraries/PayrollDataTypes.sol)

**Author:**
Yusuf

Library contract for Data types used by Payroll


## Structs
### PayrollData

```solidity
struct PayrollData {
    Status status;
    uint256 publishDate;
    uint256 startDate;
    uint256 endDate;
    uint256 revision;
    bytes32 name;
    bytes32 payrollType;
    bytes32 id;
    bytes32 dataReference;
}
```

## Enums
### Status

```solidity
enum Status {
    None,
    Active,
    Closed
}
```

