# PaperTaleCoin
[Git Source](https://gitlab.com/paper-tale-digital/blockchain/blob/3aef46fe69e8a41cefa0ac9d66abcd9403a5af24/src/tokens/PaperTaleCoin.sol)

**Inherits:**
[ERC20Interface](/src/tokens/ERC20Interface.sol/interface.ERC20Interface.md)


## State Variables
### name

```solidity
string public constant name = "PaperTale Coin";
```


### symbol

```solidity
string public constant symbol = "PTC";
```


### decimals

```solidity
uint8 public constant decimals = 2;
```


### _totalSupply

```solidity
uint256 private constant _totalSupply = 1000000000000000;
```


### _balances

```solidity
mapping(address => uint256) private _balances;
```


### _allowed

```solidity
mapping(address => mapping(address => uint256)) private _allowed;
```


## Functions
### constructor


```solidity
constructor();
```

### totalSupply


```solidity
function totalSupply() public pure returns (uint256);
```

### balanceOf


```solidity
function balanceOf(address tokenOwner) public view returns (uint256 balance);
```

### allowance


```solidity
function allowance(address tokenOwner, address spender) public view returns (uint256 remaining);
```

### transfer


```solidity
function transfer(address to, uint256 tokens) public returns (bool success);
```

### approve


```solidity
function approve(address spender, uint256 tokens) public returns (bool success);
```

### transferFrom


```solidity
function transferFrom(address from, address to, uint256 tokens) public returns (bool success);
```

### isContract


```solidity
function isContract(address addr) public view returns (bool success);
```

