# Asset
[Git Source](https://gitlab.com/paper-tale-digital/blockchain/blob/3aef46fe69e8a41cefa0ac9d66abcd9403a5af24/src/tokens/Asset.sol)

**Inherits:**
[ERC20Interface](/src/tokens/ERC20Interface.sol/interface.ERC20Interface.md)


## State Variables
### assetName

```solidity
string private assetName;
```


### assetSymbol

```solidity
string private assetSymbol;
```


### assetUnit

```solidity
string private assetUnit;
```


### assetDecimals

```solidity
uint8 private assetDecimals;
```


### assetTotalSupply

```solidity
uint256 private assetTotalSupply;
```


### _balances

```solidity
mapping(address => uint256) private _balances;
```


### _allowed

```solidity
mapping(address => mapping(address => uint256)) private _allowed;
```


### _compositionList

```solidity
address[] private _compositionList;
```


### _composition

```solidity
mapping(address => uint256) private _composition;
```


## Functions
### constructor


```solidity
constructor(string memory _name, string memory _symbol, string memory _unit, uint8 _decimals, uint256 _totalSupply);
```

### name


```solidity
function name() public view returns (string memory);
```

### symbol


```solidity
function symbol() public view returns (string memory);
```

### unit


```solidity
function unit() public view returns (string memory);
```

### decimals


```solidity
function decimals() public view returns (uint8);
```

### totalSupply


```solidity
function totalSupply() public view override returns (uint256);
```

### balanceOf


```solidity
function balanceOf(address tokenOwner) public view override returns (uint256 balance);
```

### allowance


```solidity
function allowance(address tokenOwner, address spender) public view override returns (uint256 remaining);
```

### transfer


```solidity
function transfer(address to, uint256 tokens) public override returns (bool success);
```

### approve


```solidity
function approve(address spender, uint256 tokens) public override returns (bool success);
```

### transferFrom


```solidity
function transferFrom(address from, address to, uint256 tokens) public override returns (bool success);
```

### isContract


```solidity
function isContract(address addr) public view override returns (bool success);
```

