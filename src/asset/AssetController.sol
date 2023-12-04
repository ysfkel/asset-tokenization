// SPDX-FileCopyrightText: (c) Copyright 2023 PaperTale Technologies, all rights reserved.
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {IERC1155ReceiverUpgradeable} from "@openzeppelin-upgradeable/token/ERC1155/IERC1155ReceiverUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {IAssetController} from "./interfaces/IAssetController.sol";
import {AssetControllerBase} from "./AssetControllerBase.sol";

/**
 * @title AssetController
 * @author Yusuf
 * @notice Implements AssetController
 * This contract inherits UUPS (Universal Upgradeable Proxy Standard)
 * ensure to execute the initialize function after contract deployment
 * to prevent thrid party from executing this and taking ownersip of the smart contract
 */
contract AssetController is AssetControllerBase, IAssetController, IERC1155ReceiverUpgradeable, UUPSUpgradeable {
    //////////////////////////////
    /////  Errors            /////
    //////////////////////////////
    error AssetController__ZeroAmount();
    error AssetController__NotAssetOwner();
    error AssetController__ZeroAddress();
    error AssetController__CannotConsumeToZeroAssetBalance();
    error AssetController__InsufficientAssetBalance(address sender, uint256 assetId);
    error AssetController__ExceededMaxContentPerTransaction();

    //////////////////////////////
    /////  Events            /////
    //////////////////////////////

    event BatchTransfer(address indexed from, address indexed to, uint256[] assetIds, uint256[] amounts);
    event Transfer(address indexed from, address indexed to, uint256 indexed assetId, uint256 amount);
    event Mint(
        address indexed sender, uint256 indexed assetId, uint256 amount, uint256[] contentIds, uint256[] amounts
    );

    //////////////////////////////
    /////  State variables   /////
    //////////////////////////////

    uint256 private _assetCount;
    ///////////////////////////////////////
    /////////////// Functions /////////////
    ///////////////////////////////////////

    function initialize(address assetToken, uint256 _maxContentPerTransaction) external initializer {
        __AssetControllerBase_init(assetToken, _maxContentPerTransaction);
        __UUPSUpgradeable_init();
        _assetCount = 0;
    }

    ///////////////////////////////////////
    /////  Externa & Public Functions /////
    ///////////////////////////////////////

    /// @inheritdoc IAssetController
    function mint(
        uint256 amount,
        bytes32 name,
        bytes32 symbol,
        uint256[] memory contentIds,
        uint256[] memory amounts,
        bytes32 externalContentRef,
        bytes memory data
    ) external {
        uint256 assetId = ++_assetCount;
        if (amount == 0) {
            revert AssetController__ZeroAmount();
        }

        if (_assets.isApprovedForAll(address(this), msg.sender) == false) {
            _assets.setApprovalForAll(msg.sender, true);
        }

        if (contentIds.length > 0) {
            _consume(assetId, contentIds, amounts, data);
            emit Consume(msg.sender, assetId, contentIds, amounts);
        }
        _mint(assetId, amount, name, symbol, externalContentRef, data);
        emit Mint(msg.sender, assetId, amount, contentIds, amounts);
    }

    /// @inheritdoc IAssetController
    function consume(uint256 assetId, uint256[] memory contentIds, uint256[] memory amounts, bytes memory data)
        external
    {
        if (_getAssetCreator(assetId) != msg.sender) {
            revert AssetController__NotAssetOwner();
        }

        if (_assets.balanceOf(msg.sender, assetId) == 0) {
            revert AssetController__CannotConsumeToZeroAssetBalance();
        }

        _consume(assetId, contentIds, amounts, data);
    }

    /// @inheritdoc IAssetController
    function reduceContentAmounts(
        uint256 assetId,
        uint256[] memory contentIds,
        uint256[] memory amounts,
        bytes memory data
    ) external {
        if (_getAssetCreator(assetId) != msg.sender) {
            revert AssetController__NotAssetOwner();
        }

        _reduceContentAmounts(assetId, contentIds, amounts, data);
    }

    /// @inheritdoc IAssetController
    function transfer(address to, uint256 id, uint256 amount, bytes memory data) external {
        if (amount == 0) {
            revert AssetController__ZeroAmount();
        }

        if (to == address(0)) {
            revert AssetController__ZeroAddress();
        }

        if (_assets.isApprovedForAll(to, address(this)) == false) {
            _assets.setApprovalForAll(to, true);
        }

        _assets.safeTransferFrom(msg.sender, to, id, amount, data);
        emit Transfer(msg.sender, to, id, amount);
    }

    /// @inheritdoc IAssetController
    function batchTransferFrom(address to, uint256[] memory assetIds, uint256[] memory amounts, bytes memory data)
        external
    {
        if (to == address(0)) {
            revert AssetController__ZeroAddress();
        }

        if (_assets.isApprovedForAll(address(this), to) == false) {
            _assets.setApprovalForAll(to, true);
        }

        _assets.safeBatchTransferFrom(msg.sender, to, assetIds, amounts, data);
        emit BatchTransfer(msg.sender, to, assetIds, amounts);
    }

    function onERC1155Received(address, address, uint256, uint256, bytes calldata) external pure returns (bytes4) {
        return IERC1155ReceiverUpgradeable.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address, address, uint256[] calldata, uint256[] calldata, bytes calldata)
        external
        pure
        returns (bytes4)
    {
        return IERC1155ReceiverUpgradeable.onERC1155BatchReceived.selector;
    }

    // /////////////////////////////////////
    // ////// External View Funtions ///////
    // /////////////////////////////////////

    /// @inheritdoc IAssetController
    function assetExists(uint256 assetId) external view returns (bool) {
        return _assetExists(assetId);
    }

    /// @inheritdoc IAssetController
    function isAssetOwner(uint256 assetId, address account) external view returns (bool) {
        return _getAssetCreator(assetId) == account;
    }

    /// @inheritdoc IAssetController
    function getAssetContent(uint256 assetId) external view returns (uint256[] memory) {
        return _getAssetContent(assetId);
    }

    /// @inheritdoc IAssetController
    function getAssetContentAmount(uint256 assetId, uint256 contentId) external view returns (uint256) {
        return _getAssetContentAmount(assetId, contentId);
    }

    /// @inheritdoc IAssetController
    function getAssetContentIndex(uint256 assetId, uint256 contentId) external view returns (uint256 index) {
        return _getAssetContentIndex(assetId, contentId);
    }

    /// @inheritdoc IAssetController
    function getAssetContentIndexWithRevert(uint256 assetId, uint256 contentId) external view returns (uint256 index) {
        index = _getAssetContentIndex(assetId, contentId);

        if (index > _getContentCount(assetId) - 1) {
            revert AssetController__NotAssetContent(contentId);
        }

        return index;
    }

    function getContentCount(uint256 assetId) external view returns (uint256) {
        return _getContentCount(assetId);
    }

    function getContentLength(uint256 assetId) external view returns (uint256) {
        return _getContentLength(assetId);
    }

    function getAssetExternalContentRef(uint256 assetId) external view returns (bytes32) {
        return _getAssetExternalContentRef(assetId);
    }

    function assetCount() external view returns (uint256) {
        return _assetCount;
    }

    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return (
            type(IERC1155ReceiverUpgradeable).interfaceId == interfaceId
                || type(IAssetController).interfaceId == interfaceId
        );
    }

    //////////////////////////////////////
    ///////// internal  Funtions /////////
    /////////////////////////////////////

    //@dev required by the OZ UUPS module
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
