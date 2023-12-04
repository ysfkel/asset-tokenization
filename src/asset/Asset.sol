// SPDX-FileCopyrightText: (c) Copyright 2023 PaperTale Technologies, all rights reserved.
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {
    ERC1155Upgradeable as ERC1155,
    IERC165Upgradeable
} from "@openzeppelin-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin-upgradeable/access/OwnableUpgradeable.sol";
import {Address} from "@openzeppelin/utils/Address.sol";
import {IAsset} from "./interfaces/IAsset.sol";

/**
 * @title Asset
 * @author Yusuf
 * @notice Implements IAsset.
 * This contract inherits UUPS (Universal Upgradeable Proxy Standard)
 * ensure to execute the initialize function after contract deployment
 * to prevent thrid party from executing this and taking ownersip of the smart contract
 */
contract Asset is IAsset, ERC1155, UUPSUpgradeable, OwnableUpgradeable {
    error Asset__CallerIsNotTokenOwner();
    error Asset__CallerIsNotApprovedToTransfer();
    error Asset__ZeroAddress();
    error Asset__NotController();
    error Asset__ControllerNotSet();
    error Asset__InvalidLockAddress();

    address private controller;
    mapping(uint256 assetId => bytes32 name) private _name;
    mapping(uint256 assetId => bytes32 symbol) private _symbol;

    modifier onlyController() {
        if (Address.isContract(_msgSender()) == true && _msgSender() == owner()) {
            _;
        } else {
            revert Asset__NotController();
        }
    }

    function initialize(string memory tokenUri) external initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();
        __ERC1155_init(tokenUri);
    }

    /// @inheritdoc IAsset
    function mint(address to, uint256 id, uint256 amount, bytes32 name, bytes32 symbol, bytes memory data)
        external
        onlyOwner
    {
        _mint(to, id, amount, data);
        _name[id] = name;
        _symbol[id] = symbol;
    }

    /// @inheritdoc IAsset
    function nameOf(uint256 id) external view returns (bytes32) {
        return _name[id];
    }

    /// @inheritdoc IAsset
    function symbolOf(uint256 id) external view returns (bytes32) {
        return _symbol[id];
    }

    /// @inheritdoc ERC1155
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data)
        public
        override
        onlyOwner
    {
        if (isApprovedForAll(from, _msgSender()) == false) {
            revert Asset__CallerIsNotApprovedToTransfer();
        }

        _safeTransferFrom(from, to, id, amount, data);
    }

    /// @inheritdoc ERC1155
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public override onlyOwner {
        if (isApprovedForAll(from, _msgSender()) == false) {
            revert Asset__CallerIsNotApprovedToTransfer();
        }
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    /// @inheritdoc IAsset
    function lock(address from, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        external
        onlyController
    {
        _safeBatchTransferFrom(from, _msgSender(), ids, amounts, data);
    }

    /// @inheritdoc IAsset
    function unlock(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        external
        onlyController
    {
        _safeBatchTransferFrom(_msgSender(), to, ids, amounts, data);
    }

    //@dev required by the OZ UUPS module
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    /**
     *
     * @param owner This is the asset owner
     * @param approved approves sender to control owner's assets
     */
    function setApprovalForAll(address owner, bool approved) public override onlyOwner {
        _setApprovalForAll(owner, _msgSender(), approved);
    }
}
