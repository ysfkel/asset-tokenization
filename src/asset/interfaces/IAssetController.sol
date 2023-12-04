// SPDX-FileCopyrightText: (c) Copyright 2023 PaperTale Technologies, all rights reserved.
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

/**
 * @title IAssetController
 * @author Yusuf
 * @notice Defines interface for asset mint and consume functionlaity.
 *
 */
interface IAssetController {
    /**
     * @notice mints new asset
     * @param amount Amount of asset to mint
     * @param name Name of asset
     * @param symbol Asset symbol
     * @param contentIds assets to consume / lock inorder to mint new asset
     * @param amounts amounts of contentIds to consume
     * @param externalContentRef (optional) unique file storage id of the file (eg json) that stores the contents of the asset
     * @param data refer - ERC1155 _mint
     *
     * @dev contentIds are previously minted assets which are consumed to mint new asset
     * each contentId must have its amount in amounts
     */
    function mint(
        uint256 amount,
        bytes32 name,
        bytes32 symbol,
        uint256[] calldata contentIds,
        uint256[] calldata amounts,
        bytes32 externalContentRef,
        bytes memory data
    ) external;

    /**
     * @notice consumes contents to assetId
     * @param assetId Id of asset to add contents to
     * @param contentIds Id's of assets which will be consumed
     * @param amounts amounts of contentIds
     * @param data - refer - ERC1155 _mint
     */
    function consume(uint256 assetId, uint256[] memory contentIds, uint256[] memory amounts, bytes memory data)
        external;

    /**
     * @notice Reduces the amount of consumed assets (contentIds) used to mint the specified assetId
     * @param assetId existing assetId to reduce its consumed contentIds
     * @param contentIds contentIds whose amounts to be reduced
     * @param amounts amounts of contentIds
     * @param data  refer - ERC1155 _mint
     */
    function reduceContentAmounts(
        uint256 assetId,
        uint256[] memory contentIds,
        uint256[] memory amounts,
        bytes memory data
    ) external;

    /**
     * @notice transfers assets from sender to `to` address
     * @param to receiver address
     * @param id Id of asset to transfer
     * @param amount Amount to transfer
     * @param data refer - ERC1155 _mint
     */
    function transfer(address to, uint256 id, uint256 amount, bytes memory data) external;

    /**
     * @notice batch transfer from sender to receiver `to` address
     * @param to receiver address
     * @param assetIds assets to transfer
     * @param amounts amounts of assets to transfer
     * @param data refer - ERC1155 _mint
     */
    function batchTransferFrom(address to, uint256[] memory assetIds, uint256[] memory amounts, bytes memory data)
        external;

    /**
     * @notice checks if assetId exists in memory
     * @param assetId assetId to check
     */
    function assetExists(uint256 assetId) external view returns (bool);

    /**
     * @notice checks if account owns (is minter) of assetId
     * @param assetId assetId to check
     * @param account account to check
     */
    function isAssetOwner(uint256 assetId, address account) external view returns (bool);

    /**
     *
     * @param assetId AssetId to retrive its contents
     * @return returns contents of assetId
     * @dev contents are assetIds whhich where consumed to mint assetId
     */
    function getAssetContent(uint256 assetId) external view returns (uint256[] memory);

    /**
     *
     * @param assetId assetid
     * @param contentId contentid
     * @return returns the amount of contentId
     */
    function getAssetContentAmount(uint256 assetId, uint256 contentId) external view returns (uint256);

    /**
     * @notice returns the index of the content
     * @param assetId assetId
     * @param contentId contentid
     * @return index the consumed content index
     */
    function getAssetContentIndex(uint256 assetId, uint256 contentId) external view returns (uint256 index);

    /**
     * @notice returns the index of the content. Reverts if the contentId is not a content of the asset
     * @param assetId assetId
     * @param contentId contentid
     * @return index the consumed content index
     */
    function getAssetContentIndexWithRevert(uint256 assetId, uint256 contentId) external view returns (uint256 index);

    /**
     * @notice returns count of the content of the asset
     * @param assetId asset id
     */
    function getContentCount(uint256 assetId) external view returns (uint256);

    /**
     *
     * @param assetId assetId
     * @return returns the unique file storage identifier of the assets contents if available
     */
    function getAssetExternalContentRef(uint256 assetId) external view returns (bytes32);
}
