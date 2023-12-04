// SPDX-FileCopyrightText: (c) Copyright 2023 PaperTale Technologies, all rights reserved.
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Document} from "../types.sol";

/**
 * @title IAssetDocument
 * @author Yusuf
 * @notice Interface specification for AssetDocument
 */
interface IAssetDocument {
    /**
     * @dev initializes the smart contract - This function must be called after proxy deployment
     * @param _assetController Address of AssetController contract
     */
    function initialize(address _assetController) external;

    /**
     * @notice Associates the unique storage reference of an uploaded to the specified asset Id
     * @param assetId assetId of the asset the document is asscociated with
     * @param documentId unique id storage reference of the document
     */
    function addDocument(uint256 assetId, bytes32 documentId) external;

    /**
     * @notice Associates the unique storage reference of an uploaded external audit document to the specified asset Id
     * @param assetId assetId of the asset the document is asscociated with
     * @param documentId unique id storage reference of the document
     */
    function addExternalAudit(uint256 assetId, bytes32 documentId) external;

    /**
     * @notice Associates the unique storage reference of an uploaded internal audit document to the specified asset Id
     * @param assetId assetId of the asset the document is asscociated with
     * @param documentId unique id storage reference of the document
     */
    function addInternalAudit(uint256 assetId, bytes32 documentId) external;

    /**
     * @notice sets the address of an external autitor. This is the account allowed to upload external audot for the specified assetId
     * @param assetId assetId
     * @param account external auditor address
     */
    function setExternalAuditor(uint256 assetId, address account) external;

    /**
     * @notice returns the address of the external auditor for the specified assetId
     * @param assetId assetId
     * @return externalAuditorAddress external auditor address
     */
    function getExternalAuditorAddress(uint256 assetId) external view returns (address externalAuditorAddress);

    /**
     * @notice returns the external audit for the specified assetId
     * @param assetId assetId of asset
     */
    function getExternalAudit(uint256 assetId) external view returns (Document memory);

    /**
     * @notice returns documentId of external audit for the specified assetId
     * @param assetId AssetId
     * @return documentId external audit document id
     */
    function getExternalAuditId(uint256 assetId) external view returns (bytes32 documentId);

    /**
     * @notice returns the internal audit for the specified assetId
     * @param assetId assetId of asset
     */
    function getInternalAudit(uint256 assetId) external view returns (Document memory);

    /**
     * @notice returns documentId of internal audit for the specified assetId
     * @param assetId AssetId
     * @return documentId internal audit document id
     */
    function getInternalAuditId(uint256 assetId) external view returns (bytes32);

    /**
     * @notice returns list of documentIds for the specified assetId
     * @param assetId asset Id
     */
    function getAssetDocumentIds(uint256 assetId) external view returns (bytes32[] memory);

    /**
     * returns the document dor the specified assetId and documentId combination
     * @param assetId assetId of asset
     * @param documentId documentId of document
     */
    function getAssetDocument(uint256 assetId, bytes32 documentId) external view returns (Document memory);

    /**
     * @notice returns the AssetController address
     */
    function getAssetController() external view returns (address);
}
