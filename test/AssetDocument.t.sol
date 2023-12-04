// SPDX-FileCopyrightText: (c) Copyright 2023 PaperTale Technologies, all rights reserved.
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import {Asset} from "../src/asset/Asset.sol";
import {AssetProxy} from "../src/asset/AssetProxy.sol";
import {AssetController} from "../src/asset/AssetController.sol";
import {AssetControllerProxy} from "../src/asset/AssetControllerProxy.sol";
import {AssetDocument} from "../src/asset/AssetDocument.sol";
import {AssetDocumentProxy} from "../src/asset/AssetDocumentProxy.sol";
import {Document} from "../src/asset/types.sol";
/**
 * @title AssetControllerTest
 * @author Yusuf
 * @notice Tests for Asset contract
 */

contract AssetControllerTest is Test {
    event AddDocument(address indexed sender, uint256 indexed assetId, bytes32 indexed documentId, uint256 timestamp);
    event AddExternalAudit(
        address indexed sender, uint256 indexed assetId, bytes32 indexed documentId, uint256 timestamp
    );
    event AddInternalAudit(
        address indexed sender, uint256 indexed assetId, bytes32 indexed documentId, uint256 timestamp
    );
    event SetExternalAuditor(address indexed sender, uint256 indexed assetId, address account);

    address USER1 = makeAddr("TEST_USER_1");
    address USER2 = makeAddr("TEST_USER_2");
    address USER3 = makeAddr("TEST_USER_3");
    address asset_implementation = address(new Asset());
    address assetProxy;
    address controllerImplentation;
    address documentImplementation;
    string tokenUri = "/fake-token-url";
    AssetController controller;
    Asset assets;
    AssetDocument assetDoc;

    event BatchTransfer(address indexed from, address indexed to, uint256[] assetIds, uint256[] amounts);
    event Transfer(address indexed from, address indexed to, uint256 indexed assetId, uint256 amount);
    event Consume(address indexed sender, uint256 indexed assetId, uint256[] contentIds, uint256[] amounts);
    event Mint(
        address indexed sender, uint256 indexed assetId, uint256 amount, uint256[] contentIds, uint256[] amounts
    );

    function setUp() public {
        vm.startPrank(msg.sender);
        asset_implementation = address(new Asset());
        controllerImplentation = address(new AssetController());
        documentImplementation = address(new AssetDocument());
        /// Asset
        assetProxy = address(new AssetProxy(address(asset_implementation), abi.encodeCall(Asset.initialize, tokenUri)));
        assets = Asset(assetProxy);
        /// AssetController
        address controllerProxy = address(
            new AssetControllerProxy(controllerImplentation, abi.encodeCall(AssetController.initialize, (assetProxy, 10)))
        );
        controller = AssetController(controllerProxy);
        assets.transferOwnership(address(controller));
        // init doc
        bytes memory _data = abi.encodeCall(AssetDocument.initialize, controllerProxy);
        address documentProxy = address(new AssetDocumentProxy(documentImplementation, _data));
        assetDoc = AssetDocument(documentProxy);
        vm.stopPrank();
        mintAssets();
    }

    ///////////////////////////////////////
    ////////     Initializer Tests    /////
    ///////////////////////////////////////

    function test_initizlize__sets_state_variables() public {
        assertEq(address(controller), assetDoc.getAssetController());
    }

    function test_addDocument_reverts_with_CallerIsNotAssetOwner() public {
        vm.startPrank(msg.sender);
        vm.expectRevert(AssetDocument.AssetDocument__CallerIsNotAssetOwner.selector);
        assetDoc.addDocument(1, bytes32("doc1"));
        vm.stopPrank();
    }

    function test_addDocument_succeeds() public {
        vm.startPrank(USER1);
        bytes32 documentId = bytes32("doc1");
        vm.expectEmit(true, false, false, false);
        emit AddDocument(USER1, 1, documentId, block.timestamp);
        assetDoc.addDocument(1, documentId);
        Document memory doc = assetDoc.getAssetDocument(1, documentId);
        bytes32[] memory docId = assetDoc.getAssetDocumentIds(1);
        assertEq(docId.length, 1);
        assertEq(docId[0], documentId);
        assertEq(doc.account, USER1);
        assertEq(doc.assetId, 1);
        assertEq(doc.documentId, documentId);
        vm.stopPrank();
    }

    function test_addExternalAudit_reverts_with_CallerIsNotAssetExternalAuditor_2() public {
        // SET user2 as externalAuditor
        vm.startPrank(USER1);
        assetDoc.setExternalAuditor(1, USER2);
        vm.stopPrank();
        // msg.sender tries to add audit (not audito)
        vm.startPrank(msg.sender);
        vm.expectRevert(AssetDocument.AssetDocument__CallerIsNotAssetExternalAuditor.selector);
        assetDoc.addExternalAudit(1, bytes32("audit"));
        vm.stopPrank();
    }

    function test_addExternalAudit_reverts_with_ExternalAuditExists() public {
        vm.startPrank(USER1);
        assetDoc.setExternalAuditor(1, USER2);
        vm.stopPrank();

        vm.startPrank(USER2);
        assetDoc.addExternalAudit(1, bytes32("audit"));
        vm.expectRevert(AssetDocument.AssetDocument__ExternalAuditExists.selector);
        assetDoc.addExternalAudit(1, bytes32("audit"));
        vm.stopPrank();
    }

    function test_addExternalAudit_succeeds() public {
        vm.startPrank(USER1);
        assetDoc.setExternalAuditor(1, USER2);
        vm.stopPrank();
        vm.startPrank(USER2);
        bytes32 documentId = bytes32("doc1");
        vm.expectEmit(true, false, false, false);
        emit AddExternalAudit(USER2, 1, documentId, block.timestamp);
        assetDoc.addExternalAudit(1, documentId);
        Document memory doc = assetDoc.getExternalAudit(1);
        bytes32 docId = assetDoc.getExternalAuditId(1);
        assertEq(docId, documentId);
        assertEq(doc.account, USER2);
        assertEq(doc.assetId, 1);
        assertEq(doc.documentId, documentId);
        vm.stopPrank();
    }

    function test_addInternalAudit_reverts_with__CallerIsNotAssetOwner() public {
        vm.startPrank(USER2);
        vm.expectRevert(AssetDocument.AssetDocument__CallerIsNotAssetOwner.selector);
        assetDoc.addInternalAudit(1, bytes32("doc1"));
        vm.stopPrank();
    }

    function test_addExternalAudit_reverts_with__InternalAuditExists() public {
        vm.startPrank(USER1);
        assetDoc.addInternalAudit(1, bytes32("audit"));
        vm.expectRevert(AssetDocument.AssetDocument__InternalAuditExists.selector);
        assetDoc.addInternalAudit(1, bytes32("audit"));
        vm.stopPrank();
    }

    function test_addInternalAudit_succeeds() public {
        vm.startPrank(USER1);
        bytes32 documentId = bytes32("doc1");
        vm.expectEmit(true, false, false, false);
        emit AddInternalAudit(USER1, 1, documentId, block.timestamp);
        assetDoc.addInternalAudit(1, documentId);
        Document memory doc = assetDoc.getInternalAudit(1);
        bytes32 docId = assetDoc.getInternalAuditId(1);
        assertEq(docId, documentId);
        assertEq(doc.account, USER1);
        assertEq(doc.assetId, 1);
        assertEq(doc.documentId, documentId);
        vm.stopPrank();
    }

    function test_setExternalAuditor_reverts_with_CallerIsNotAssetOwner() public {
        vm.startPrank(msg.sender);
        vm.expectRevert(AssetDocument.AssetDocument__CallerIsNotAssetOwner.selector);
        assetDoc.setExternalAuditor(1, USER2);
        vm.stopPrank();
    }

    function test_setExternalAuditor_succeeds() public {
        vm.startPrank(USER1);
        assetDoc.setExternalAuditor(1, USER2);
        assertEq(assetDoc.getExternalAuditorAddress(1), USER2);
        vm.stopPrank();
    }

    function test_addExternalAudit_reverts_with_CallerIsNotAssetExternalAuditor() public {
        vm.startPrank(msg.sender);
        vm.expectRevert(AssetDocument.AssetDocument__CallerIsNotAssetExternalAuditor.selector);
        assetDoc.addExternalAudit(1, bytes32("audit"));
        vm.stopPrank();
    }

    function mintAssets() private {
        vm.startPrank(USER1);
        controller.mint(
            500e18, bytes32("Fabric"), bytes32("FAB"), new uint256[](0), new uint256[](0), bytes32("external_ref"), ""
        );
        controller.transfer(USER3, 1, 500e18, "");
        vm.stopPrank();

        vm.startPrank(USER2);
        controller.mint(
            500e18, bytes32("Fabric2"), bytes32("FAB2"), new uint256[](0), new uint256[](0), bytes32("external_ref"), ""
        );
        controller.transfer(USER3, 2, 500e18, "");
        vm.stopPrank();

        uint256[] memory contentIds = new uint256[](2);
        uint256[] memory amounts = new uint256[](2);
        contentIds[0] = 1;
        contentIds[1] = 2;
        amounts[0] = 400e18;
        amounts[1] = 300e18;

        vm.startPrank(USER3);
        controller.mint(1000e18, bytes32("ITEM1"), bytes32("ITM1"), contentIds, amounts, bytes32("external_ref"), "");
        vm.stopPrank();
    }
}
