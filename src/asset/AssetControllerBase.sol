// SPDX-FileCopyrightText: (c) Copyright 2023 PaperTale Technologies, all rights reserved.
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {OwnableUpgradeable} from "@openzeppelin-upgradeable/access/OwnableUpgradeable.sol";
import {Asset} from "./Asset.sol";

/**
 * @title AssetController
 * @author Yusuf
 * @notice Base contract for AssetController
 */
contract AssetControllerBase is OwnableUpgradeable {
    //////////////////////////////
    /////  Errors            /////
    //////////////////////////////

    error AssetController__UnknownAsset(uint256 assetId);
    error AssetController__ContentIdsAmountsMismatch(uint256 assetIdsLength, uint256 amountsLength);
    error AssetController__ExceedsMaxAllowedContentIdPerTransaction();
    // User cannot send contentId with corresponding 0 amount
    error AssetController__ZeroContentAmount(uint256 contentId);
    error AssetController__ZeroByes32();
    error AssetController__NotAssetContent(uint256 contentId);
    error AssetController__AmountGreaterThanStoredAmount(uint256 contentId, uint256 currentAmount, uint256 reduceAmount);
    error AssetController__InputContentIdsExceedsStoredContentCount();

    //////////////////////////////
    /////  Event            /////
    //////////////////////////////
    event Consume(address indexed sender, uint256 indexed assetId, uint256[] contentIds, uint256[] amounts);

    //////////////////////////////
    /////  State variables   /////
    //////////////////////////////

    uint256 private _maxContentPerTransaction;
    Asset internal _assets;
    mapping(uint256 assetId => address owner) private _assetCreator;
    mapping(uint256 assetId => uint256[] contentIds) private _assetContent;
    mapping(uint256 assetId => mapping(uint256 contentId => uint256 amount)) private _assetContentAmount;
    mapping(uint256 assetId => mapping(uint256 contentId => uint256 index)) private _assetContentIndex;
    mapping(uint256 assetid => uint256 contentCount) private _assetContentCount;
    mapping(uint256 assetId => bytes32 externalContentRef) private _assetExternalContentRef;
    ///////////////////////////////////////
    /////////////// Functions /////////////
    ///////////////////////////////////////

    function __AssetControllerBase_init(address assetToken, uint256 __maxContentPerTransaction) internal initializer {
        __Ownable_init();
        _assets = Asset(assetToken);
        _maxContentPerTransaction = __maxContentPerTransaction;
    }

    /////////////////////////////////////
    ///////// External  Funtions /////////
    /////////////////////////////////////

    /**
     * @notice sets maxContentPerTransactionts
     * @param _value maximum number of assets (contentIds) that can be consumed in a transaction
     * @dev this is a protetion mechanism to prevent too many contentIds passed to the consume or mint transaction
     */
    function setMaxContentPerTransaction(uint256 _value) external onlyOwner {
        _maxContentPerTransaction = _value;
    }

    /**
     * @param assetId assetId
     * @param _externalContentRef unique file storage identifier of asset content file
     */
    function setAssetExternalContentRef(uint256 assetId, bytes32 _externalContentRef) external onlyOwner {
        if (_assetExists(assetId) == false) {
            revert AssetController__UnknownAsset(assetId);
        }

        if (_externalContentRef == bytes32(0)) {
            revert AssetController__ZeroByes32();
        }
        _assetExternalContentRef[assetId] = _externalContentRef;
    }

    /////////////////////////////////////
    ///////// External view  Funtions /////////
    /////////////////////////////////////

    function maxContentPerTransaction() external view returns (uint256) {
        return _maxContentPerTransaction;
    }

    function assets() external view returns (address) {
        return address(_assets);
    }

    /////////////////////////////////////
    ///////// internal  Funtions /////////
    /////////////////////////////////////

    function _consume(uint256 assetId, uint256[] memory contentIds, uint256[] memory amounts, bytes memory data)
        internal
    {
        if (contentIds.length != amounts.length) {
            revert AssetController__ContentIdsAmountsMismatch(contentIds.length, amounts.length);
        }

        if (contentIds.length > _maxContentPerTransaction) {
            revert AssetController__ExceedsMaxAllowedContentIdPerTransaction();
        }

        uint256[] storage contents = _assetContent[assetId];

        mapping(uint256 contentId => uint256 amount) storage _contentAmounts = _assetContentAmount[assetId];
        mapping(uint256 contentId => uint256 amount) storage _contentIndex = _assetContentIndex[assetId];
        uint256 _contentCount = _assetContentCount[assetId];

        for (uint256 i = 0; i < contentIds.length; i++) {
            if (amounts[i] == 0) {
                revert AssetController__ZeroContentAmount(contentIds[i]);
            }

            if (_assetExists(contentIds[i]) == false) {
                revert AssetController__UnknownAsset(contentIds[i]);
            }

            if (_contentAmounts[contentIds[i]] == 0) {
                _contentIndex[contentIds[i]] = _contentCount; // assign be increment _contentCount
                contents.push(contentIds[i]);
                _contentCount += 1;
            }

            _contentAmounts[contentIds[i]] += amounts[i];
        }
        _assetContentCount[assetId] = _contentCount;
        _assets.lock(msg.sender, contentIds, amounts, data);
        emit Consume(msg.sender, assetId, contentIds, amounts);
    }

    function _reduceContentAmounts(
        uint256 assetId,
        uint256[] memory contentIds,
        uint256[] memory amounts,
        bytes memory data
    ) internal {
        if (contentIds.length != amounts.length) {
            revert AssetController__ContentIdsAmountsMismatch(contentIds.length, amounts.length);
        }

        if (contentIds.length > _getContentCount(assetId)) {
            revert AssetController__InputContentIdsExceedsStoredContentCount();
        }

        uint256 _contentCount = _assetContentCount[assetId];
        uint256[] storage contents = _assetContent[assetId];
        uint256 _contentLength = contents.length;
        mapping(uint256 contentId => uint256 amount) storage contentAmounts = _assetContentAmount[assetId];

        for (uint256 i = 0; i < contentIds.length; i++) {
            if (amounts[i] == 0) {
                revert AssetController__ZeroContentAmount(contentIds[i]);
            }
            uint256 contentAmount = contentAmounts[contentIds[i]];

            if (contentAmount == 0) {
                revert AssetController__NotAssetContent(contentIds[i]);
            }

            if (amounts[i] > contentAmount) {
                revert AssetController__AmountGreaterThanStoredAmount(contentIds[i], contentAmount, amounts[i]);
            }

            contentAmount -= amounts[i];
            uint256 swapIndex = _contentLength - ((_contentLength - _contentCount) + 1);
            uint256 swapContentId = contents[swapIndex];

            // if contentAmount is 0, we remove the content from storage
            // so that it is no longer a content of the asset
            if (contentAmount == 0) {
                // if substraction results in contentAmount being zero
                // we remove contentId from the contents of the assetId
                uint256 index = _assetContentIndex[assetId][contentIds[i]];
                if (index != swapIndex) {
                    _assetContentIndex[assetId][contentIds[i]] = swapIndex; // moves removed contentId index towards the end of the list
                    _assetContentIndex[assetId][swapContentId] = index;
                    contents[index] = swapContentId;
                }
                _contentCount -= 1;
                delete _assetContentAmount[assetId][contentIds[i]];
            }
            contentAmounts[contentIds[i]] = contentAmount;
        }
        _assetContentCount[assetId] = _contentCount;
        _removeContentIds(contents, _contentCount, _contentLength);
        _assets.unlock(msg.sender, contentIds, amounts, data);
    }

    function _removeContentIds(uint256[] storage contents, uint256 _contentCount, uint256 _contentLength) internal {
        if (_contentCount != _contentLength) {
            for (uint256 i = _contentCount; i < _contentLength; i++) {
                contents.pop();
            }
        }
    }

    function _mint(
        uint256 id,
        uint256 amount,
        bytes32 name,
        bytes32 symbol,
        bytes32 externalContentRef,
        bytes memory data
    ) internal {
        if (externalContentRef != bytes32(0)) {
            _assetExternalContentRef[id] = externalContentRef;
        }
        _assetCreator[id] = msg.sender;
        _assets.mint(msg.sender, id, amount, name, symbol, data);
    }

    /////////////////////////////////////
    ////// Internal View Funtions ///////
    /////////////////////////////////////

    function _assetExists(uint256 assetId) internal view returns (bool) {
        return _getAssetCreator(assetId) != address(0);
    }

    function _getContentCount(uint256 assetId) internal view returns (uint256) {
        return _assetContentCount[assetId];
    }

    function _getAssetCreator(uint256 assetId) internal view returns (address) {
        return _assetCreator[assetId];
    }

    function _getAssetContent(uint256 assetId) internal view returns (uint256[] memory) {
        return _assetContent[assetId];
    }

    function _getAssetContentAmount(uint256 assetId, uint256 contentId) internal view returns (uint256) {
        return _assetContentAmount[assetId][contentId];
    }

    function _getAssetContentIndex(uint256 assetId, uint256 contentId) internal view returns (uint256 index) {
        return _assetContentIndex[assetId][contentId];
    }

    function _getContentLength(uint256 assetId) internal view returns (uint256) {
        return _assetContent[assetId].length;
    }

    function _getAssetExternalContentRef(uint256 assetId) internal view returns (bytes32) {
        return _assetExternalContentRef[assetId];
    }
}
