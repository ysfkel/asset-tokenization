// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "./ERC20Interface.sol";

contract PaperTaleCoin is ERC20Interface {
    string public constant name = "PaperTale Coin";
    string public constant symbol = "PTC";
    uint8 public constant decimals = 2;

    uint256 private constant _totalSupply = 1000000000000000;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowed;

    constructor() {
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function totalSupply() public pure returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address tokenOwner) public view returns (uint256 balance) {
        return _balances[tokenOwner];
    }

    function allowance(address tokenOwner, address spender) public view returns (uint256 remaining) {
        return _allowed[tokenOwner][spender];
    }

    function transfer(address to, uint256 tokens) public returns (bool success) {
        assert(!isContract(to) && msg.sender != to && tokens > 0 && _balances[msg.sender] >= tokens);
        _balances[msg.sender] -= tokens;
        _balances[to] += tokens;
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function approve(address spender, uint256 tokens) public returns (bool success) {
        assert(tokens > 0 && _balances[msg.sender] >= tokens);
        _allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint256 tokens) public returns (bool success) {
        assert(from != to && tokens > 0 && _balances[from] >= tokens && allowance(from, to) >= tokens);
        _allowed[from][to] -= tokens;
        _balances[from] -= tokens;
        _balances[to] += tokens;
        emit Transfer(from, to, tokens);
        return true;
    }

    function isContract(address addr) public view returns (bool success) {
        uint256 codeSize;
        assembly {
            codeSize := extcodesize(addr)
        }
        return codeSize > 0;
    }
}
