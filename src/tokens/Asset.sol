// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "./ERC20Interface.sol";

contract Asset is ERC20Interface {
    string private assetName;
    string private assetSymbol;
    string private assetUnit;
    uint8 private assetDecimals;

    uint256 private assetTotalSupply;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowed;

    address[] private _compositionList;
    mapping(address => uint256) private _composition;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _unit,
        uint8 _decimals,
        uint256 _totalSupply
    ) {
        assetName = _name;
        assetSymbol = _symbol;
        assetUnit = _unit;
        assetDecimals = _decimals;
        assetTotalSupply = _totalSupply;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function name() public view returns (string memory) {
        return assetName;
    }

    function symbol() public view returns (string memory) {
        return assetSymbol;
    }

    function unit() public view returns (string memory) {
        return assetUnit;
    }

    function decimals() public view returns (uint8) {
        return assetDecimals;
    }

    function totalSupply() public view override returns (uint256) {
        return assetTotalSupply;
    }

    function balanceOf(address tokenOwner) public view override returns (uint256 balance) {
        return _balances[tokenOwner];
    }

    function allowance(address tokenOwner, address spender) public view override returns (uint256 remaining) {
        return _allowed[tokenOwner][spender];
    }

    function transfer(address to, uint256 tokens) public override returns (bool success) {
        assert(!isContract(to) && msg.sender != to && tokens > 0 && _balances[msg.sender] >= tokens);
        _balances[msg.sender] -= tokens;
        _balances[to] += tokens;
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function approve(address spender, uint256 tokens) public override returns (bool success) {
        assert(tokens > 0 && _balances[msg.sender] >= tokens);
        _allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint256 tokens) public override returns (bool success) {
        assert(from != to && tokens > 0 && _balances[from] >= tokens && allowance(from, to) >= tokens);
        _allowed[from][to] -= tokens;
        _balances[from] -= tokens;
        _balances[to] += tokens;
        emit Transfer(from, to, tokens);
        return true;
    }

    function isContract(address addr) public view override returns (bool success) {
        uint256 codeSize;
        assembly {
            codeSize := extcodesize(addr)
        }
        return codeSize > 0;
    }
}
