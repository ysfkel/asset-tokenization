# ERC20Interface
[Git Source](https://gitlab.com/paper-tale-digital/blockchain/blob/3aef46fe69e8a41cefa0ac9d66abcd9403a5af24/src/tokens/ERC20Interface.sol)


## Functions
### totalSupply


```solidity
function totalSupply() external view returns (uint256);
```

### balanceOf


```solidity
function balanceOf(address tokenOwner) external view returns (uint256 balance);
```

### allowance


```solidity
function allowance(address tokenOwner, address spender) external view returns (uint256 remaining);
```

### transfer


```solidity
function transfer(address to, uint256 tokens) external returns (bool success);
```

### approve


```solidity
function approve(address spender, uint256 tokens) external returns (bool success);
```

### transferFrom


```solidity
function transferFrom(address from, address to, uint256 tokens) external returns (bool success);
```

### isContract


```solidity
function isContract(address addr) external returns (bool success);
```

## Events
### Transfer

```solidity
event Transfer(address indexed from, address indexed to, uint256 tokens);
```

### Approval

```solidity
event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
```

