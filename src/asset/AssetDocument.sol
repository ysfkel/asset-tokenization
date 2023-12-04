// SPDX-FileCopyrightText: (c) Copyright 2023 PaperTale Technologies, all rights reserved.
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {UUPSUpgradeable} from "@openzeppelin-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin-upgradeable/access/OwnableUpgradeable.sol";
import {IAssetController} from "./interfaces/IAssetController.sol";
import {IAssetDocument} from "./interfaces/IAssetDocument.sol";
import {Document} from "./types.sol";

/**
 * @title AssetDocument
 * @author Yusuf
 * @notice This contract is Asset documents storage references and interracts with the AssetController
 * @dev This is a UUPs upgradeable contract and the initialize function MUST be called immediately
 * after contract deployment to take ownership of the contract. Not doing this leaves the contract vulnerable to
 * a malicious attack of someone initializing the contract and taking ownership
 */
contract AssetDocument is UUPSUpgradeable, OwnableUpgradeable, IAssetDocument {
    //////////////////////////////
    /////  Errors            /////
    //////////////////////////////
    error AssetDocument__ZeroAddress();
    error AssetDocument__ZeroBytes32();
    error AssetDocument__NoMatchingAsset();
    error AssetDocument__CallerIsNotAssetOwner();
    error AssetDocument__CallerIsNotAssetExternalAuditor();
    error AssetDocument__ExternalAuditExists();
    error AssetDocument__InternalAuditExists();

    //////////////////////////////
    /////  Events            /////
    //////////////////////////////
    event AddDocument(address indexed sender, uint256 indexed assetId, bytes32 indexed documentId, uint256 timestamp);
    event AddExternalAudit(
        address indexed sender, uint256 indexed assetId, bytes32 indexed documentId, uint256 timestamp
    );
    event AddInternalAudit(
        address indexed sender, uint256 indexed assetId, bytes32 indexed documentId, uint256 timestamp
    );
    event SetExternalAuditor(address indexed sender, uint256 indexed assetId, address account);
    //////////////////////////////
    /////  State variables   /////
    //////////////////////////////

    // stores address that are allowed to verify a document
    IAssetController private controller;
    // documents
    mapping(uint256 assetId => address account) private externalAuditor;
    // ids of documents attached the asset by the asset owner
    mapping(uint256 assetid => bytes32[] documentId) assetDocumentIds;
    // documents attached to asset by the asset owner
    mapping(uint256 assetId => mapping(bytes32 documentId => Document)) private assetDocument;
    // internal audit
    mapping(uint256 assetId => Document document) private internalAudit;
    mapping(uint256 assetId => bytes32 documnetId) private internalAuditId;
    // external audit
    mapping(uint256 assetId => Document document) private externalAudit;
    mapping(uint256 assetId => bytes32 documentId) private externalAuditId;

    modifier onlyAssetOwner(uint256 assetId) {
        if (controller.isAssetOwner(assetId, msg.sender) == false) {
            revert AssetDocument__CallerIsNotAssetOwner();
        }
        _;
    }

    ///////////////////////////////////////
    /////////////// Functions /////////////
    ///////////////////////////////////////

    function initialize(address _controller) external initializer {
        if (_controller == address(0)) {
            revert AssetDocument__ZeroAddress();
        }
        // todo - check controller is smart contract address
        __Ownable_init();
        __UUPSUpgradeable_init();
        controller = IAssetController(_controller);
    }

    ///////////////////////////////////////
    /////  Externa & Public Functions /////
    ///////////////////////////////////////

    /// @inheritdoc IAssetDocument
    function addDocument(uint256 assetId, bytes32 documentId) external onlyAssetOwner(assetId) {
        if (documentId == bytes32(0)) {
            revert AssetDocument__ZeroBytes32();
        }

        uint256 timestamp = block.timestamp;

        assetDocument[assetId][documentId] =
            Document({assetId: assetId, documentId: documentId, timestamp: timestamp, account: msg.sender});

        assetDocumentIds[assetId].push(documentId);

        emit AddDocument(msg.sender, assetId, documentId, timestamp);
    }

    /// @inheritdoc IAssetDocument
    function addExternalAudit(uint256 assetId, bytes32 documentId) external {
        if (msg.sender != externalAuditor[assetId]) {
            revert AssetDocument__CallerIsNotAssetExternalAuditor();
        }

        if (externalAuditId[assetId] == documentId) {
            revert AssetDocument__ExternalAuditExists();
        }

        uint256 timestamp = block.timestamp;

        externalAudit[assetId] =
            Document({assetId: assetId, account: msg.sender, timestamp: timestamp, documentId: documentId});

        externalAuditId[assetId] = documentId;

        emit AddExternalAudit(msg.sender, assetId, documentId, timestamp);
    }

    /// @inheritdoc IAssetDocument
    function addInternalAudit(uint256 assetId, bytes32 documentId) external onlyAssetOwner(assetId) {
        if (controller.isAssetOwner(assetId, msg.sender) == false) {
            revert AssetDocument__CallerIsNotAssetOwner();
        }

        if (internalAuditId[assetId] == documentId) {
            revert AssetDocument__InternalAuditExists();
        }

        uint256 timestamp = block.timestamp;

        internalAudit[assetId] =
            Document({assetId: assetId, documentId: documentId, account: msg.sender, timestamp: block.timestamp});

        internalAuditId[assetId] = documentId;

        emit AddInternalAudit(msg.sender, assetId, documentId, timestamp);
    }

    /// @inheritdoc IAssetDocument
    function setExternalAuditor(uint256 assetId, address account) external onlyAssetOwner(assetId) {
        externalAuditor[assetId] = account;

        emit SetExternalAuditor(msg.sender, assetId, account);
    }

    /////////////////////////////////////
    ////// External View Funtions ///////
    /////////////////////////////////////

    /// @inheritdoc IAssetDocument
    function getExternalAuditorAddress(uint256 assetId) external view returns (address auitorAddress) {
        return externalAuditor[assetId];
    }

    /// @inheritdoc IAssetDocument
    function getExternalAudit(uint256 assetId) external view returns (Document memory document) {
        return externalAudit[assetId];
    }

    /// @inheritdoc IAssetDocument
    function getExternalAuditId(uint256 assetId) external view returns (bytes32 documentId) {
        return externalAuditId[assetId];
    }

    /// @inheritdoc IAssetDocument
    function getInternalAudit(uint256 assetId) external view returns (Document memory document) {
        return internalAudit[assetId];
    }

    /// @inheritdoc IAssetDocument
    function getInternalAuditId(uint256 assetId) external view returns (bytes32 documentId) {
        return internalAuditId[assetId];
    }

    /// @inheritdoc IAssetDocument
    function getAssetDocumentIds(uint256 assetId) external view returns (bytes32[] memory) {
        return assetDocumentIds[assetId];
    }

    /// @inheritdoc IAssetDocument
    function getAssetDocument(uint256 assetId, bytes32 documentId) external view returns (Document memory) {
        return assetDocument[assetId][documentId];
    }

    /// @inheritdoc IAssetDocument
    function getAssetController() external view returns (address) {
        return address(controller);
    }

    //////////////////////////////////////
    ///////// internal  Funtions /////////
    //////////////////////////////////////

    //@dev required by the OZ UUPS module
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
