// SPDX-FileCopyrightText: (c) Copyright 2023 PaperTale Technologies, all rights reserved.
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import {PayrollProxy} from "../src/payroll/PayrollProxy.sol";
import "../src/payroll/Payroll.sol";
import {PayrollDataTypes as P} from "../src/payroll/libraries/PayrollDataTypes.sol";

/**
 * @title PayrollTest
 * @author Yusuf
 * @notice Tests for Payroll contract
 */
contract PayrollTest is Test {
    address payrollImplAddress;
    address payrollBeacon;
    address payrollAddress;
    address USER = makeAddr("TEST_USER");

    event PayrollCreated(address indexed payrollAddress);
    event PayrollAdded(bytes32 indexed id, uint256 publishDate);
    event PayrollClosed(bytes32 indexed id);
    event DataReferenceAdded();

    function setUp() public {}

    /////////////////////////////////////////
    //// initialize Tests //////////////////
    ////////////////////////////////////////

    function test_initializeIsCalled() public {
        Payroll payroll = new Payroll();
        vm.startPrank(msg.sender);
        payroll.initialize();
        vm.expectRevert("Initializable: contract is already initialized");
        payroll.initialize();
        vm.stopPrank();
    }

    /////////////////////////////////////////
    //// addPayroll Tests //////////////////
    ////////////////////////////////////////

    function test_addPayroll_should_revert_with_onlyOwner() public {
        Payroll payroll = new Payroll();
        payroll.initialize();
        bytes32 id = bytes32("id");
        bytes32 dataReference = bytes32("payroll_identifier");
        vm.expectRevert(abi.encodeWithSelector(Payroll.Payroll__AccessControl__CallerIsNotOwnerRole.selector, USER));
        vm.startPrank(USER);
        payroll.addPayroll(
            block.timestamp, block.timestamp, 1, bytes32("name"), bytes32("payroll_type"), id, dataReference
        );
        vm.stopPrank();
    }

    function test_addPayroll_should_revert_with_InvalidID() public {
        vm.startPrank(msg.sender);
        Payroll payroll = new Payroll();
        payroll.initialize();
        payroll.grantOwnerRole(msg.sender);
        bytes32 id = bytes32(0);
        bytes32 dataReference = bytes32("payroll_identifier");
        vm.expectRevert(Payroll.Payroll__InvalidID.selector);
        payroll.addPayroll(
            block.timestamp, block.timestamp, 1, bytes32("name"), bytes32("payroll_type"), id, dataReference
        );
        vm.stopPrank();
    }

    function test_addPayroll_should_revert_with_PatrolExists() public {
        vm.startPrank(msg.sender);
        Payroll payroll = new Payroll();
        payroll.initialize();
        payroll.grantOwnerRole(msg.sender);
        bytes32 id = bytes32("1");
        payroll.addPayroll(
            block.timestamp,
            block.timestamp,
            1,
            bytes32("name"),
            bytes32("payroll_type"),
            id,
            bytes32("payroll_identifier")
        );
        vm.expectRevert(Payroll.Payroll__AlreadyExists.selector);
        payroll.addPayroll(
            block.timestamp,
            block.timestamp,
            1,
            bytes32("name"),
            bytes32("payroll_type"),
            id,
            bytes32("payroll_identifier")
        );
        vm.stopPrank();
    }

    function test_addPayroll_should_succeed() public {
        vm.startPrank(msg.sender);
        Payroll payroll = new Payroll();
        payroll.initialize();
        payroll.grantOwnerRole(msg.sender);
        payroll.grantReadRole(msg.sender);
        uint256 revision = 1;
        uint256 start = block.timestamp;
        uint256 end = block.timestamp;
        bytes32 id = bytes32("id");
        bytes32 dataReference = "payroll_identifier";
        bytes32 name = bytes32("name");
        bytes32 payroll_type = bytes32("payroll_type");
        P.PayrollData memory p = payroll.getPayroll(id);
        assertEq(uint256(p.status), uint256(P.Status.None));
        vm.expectEmit(true, false, false, false);
        emit PayrollAdded(id, 123);
        payroll.addPayroll(start, end, revision, name, payroll_type, id, dataReference);
        p = payroll.getPayroll(id);
        assertEq(start, p.startDate);
        assertEq(end, p.endDate);
        assertEq(end, p.endDate);
        assertEq(payroll_type, p.payrollType);
        assertEq(id, p.id);
        assertEq(dataReference, p.dataReference);
        assertEq(uint256(p.status), uint256(P.Status.Active));
        assertEq(payroll.getPayrollIds().length, 1);
        assertEq(payroll.getPayrollDataReferences().length, 1);
        vm.stopPrank();
    }

    // /////////////////////////////////////////////////
    // //// addPayrollAndClosePayroll Tests ////////////
    // /////////////////////////////////////////////////

    function test_addPayrollAndClosePayroll_should_revert_with_onlyOwner() public {
        Payroll payroll = new Payroll();
        payroll.initialize();
        payroll.grantOwnerRole(msg.sender);
        bytes32 id = bytes32("id");
        bytes32 dataReference = bytes32("payroll_identifier");
        vm.expectRevert(abi.encodeWithSelector(Payroll.Payroll__AccessControl__CallerIsNotOwnerRole.selector, USER));
        vm.startPrank(USER);
        payroll.addPayrollAndClosePayroll(
            block.timestamp, block.timestamp, 1, bytes32("name"), bytes32("payroll_type"), id, dataReference
        );
        vm.stopPrank();
    }

    function test_addPayrollAndClosePayroll_should_revert_with_DataReferenceMustNotBeEmpty() public {
        vm.startPrank(msg.sender);
        Payroll payroll = new Payroll();
        payroll.initialize();
        payroll.grantOwnerRole(msg.sender);
        bytes32 id = bytes32("id");
        vm.expectRevert(Payroll.Payroll__DataReferenceMustNotBeEmpty.selector);
        payroll.addPayrollAndClosePayroll(
            block.timestamp, block.timestamp, 1, bytes32("name"), bytes32("payroll_type"), id, bytes32(0)
        );
        vm.stopPrank();
    }

    function test_addPayrollAndClosePayroll_should_succeed() public {
        vm.startPrank(msg.sender);
        Payroll payroll = new Payroll();
        payroll.initialize();
        payroll.grantOwnerRole(msg.sender);
        payroll.grantReadRole(msg.sender);
        uint256 revision = 1;
        uint256 start = block.timestamp;
        uint256 end = block.timestamp;
        bytes32 id = bytes32("id");
        bytes32 dataReference = "payroll_identifier";
        bytes32 name = bytes32("name");
        bytes32 payroll_type = bytes32("payroll_type");
        P.PayrollData memory p = payroll.getPayroll(id);
        assertEq(uint256(p.status), uint256(P.Status.None));
        vm.expectEmit(true, false, false, false);
        emit PayrollAdded(id, 123);
        payroll.addPayrollAndClosePayroll(start, end, revision, name, payroll_type, id, dataReference);
        p = payroll.getPayroll(id);
        assertEq(start, p.startDate);
        assertEq(end, p.endDate);
        assertEq(end, p.endDate);
        assertEq(payroll_type, p.payrollType);
        assertEq(id, p.id);
        assertEq(dataReference, p.dataReference);
        assertEq(uint256(p.status), uint256(P.Status.Closed));
        assertEq(payroll.getPayrollIds().length, 1);
        assertEq(payroll.getPayrollDataReferences().length, 1);
        vm.stopPrank();
    }

    // /////////////////////////////////////////
    // //// addDataReference Tests ////////////
    // ////////////////////////////////////////

    function test_addDataReference_should_revert_with_onlyOwner() public {
        Payroll payroll = new Payroll();
        payroll.initialize();
        bytes32 id = bytes32("id");
        vm.expectRevert(abi.encodeWithSelector(Payroll.Payroll__AccessControl__CallerIsNotOwnerRole.selector, USER));
        vm.startPrank(USER);
        payroll.addDatareference(id, bytes32("data_ref"));
        vm.stopPrank();
    }

    function test_addDataReference_should_revert_with_PayrollNotFound() public {
        vm.startPrank(msg.sender);
        Payroll payroll = new Payroll();
        payroll.initialize();
        payroll.grantOwnerRole(msg.sender);
        vm.expectRevert(Payroll.Payroll__NotFound.selector);
        payroll.addDatareference(bytes32("1"), bytes32("data_ref"));
        vm.stopPrank();
    }

    function test_addDataReference_should_revert_with_Payroll__DataReferenceMustNotBeEmpty() public {
        vm.startPrank(msg.sender);
        Payroll payroll = new Payroll();
        payroll.initialize();
        payroll.grantOwnerRole(msg.sender);
        bytes32 id = bytes32("1");
        payroll.addPayroll(
            block.timestamp,
            block.timestamp,
            1,
            bytes32("name"),
            bytes32("payroll_type"),
            id,
            bytes32("payroll_identifier")
        );
        vm.expectRevert(Payroll.Payroll__DataReferenceMustNotBeEmpty.selector);
        payroll.addDatareference(bytes32("1"), bytes32(0));
        vm.stopPrank();
    }

    function test_addDataReference_should_revert_with_Payroll__AlreadyClosed() public {
        vm.startPrank(msg.sender);
        Payroll payroll = new Payroll();
        payroll.initialize();
        payroll.grantOwnerRole(msg.sender);
        bytes32 id = bytes32("1");
        payroll.addPayroll(
            block.timestamp,
            block.timestamp,
            1,
            bytes32("name"),
            bytes32("payroll_type"),
            id,
            bytes32("payroll_identifier")
        );
        payroll.addDatareference(bytes32("1"), bytes32("data_ref"));
        payroll.closePayroll(id);
        vm.expectRevert(Payroll.Payroll__AlreadyClosed.selector);
        payroll.addDatareference(bytes32("1"), bytes32("data_ref"));
        vm.stopPrank();
    }

    function test_addDataReference_should_succeed() public {
        vm.startPrank(msg.sender);
        Payroll payroll = new Payroll();
        payroll.initialize();
        payroll.grantOwnerRole(msg.sender);
        payroll.grantReadRole(msg.sender);
        bytes32 id = bytes32("1");
        bytes32 dataRef = bytes32("data_ref");
        payroll.addPayroll(block.timestamp, block.timestamp, 1, bytes32("name"), bytes32("payroll_type"), id, dataRef);
        vm.expectEmit();
        emit DataReferenceAdded();
        payroll.addDatareference(bytes32("1"), dataRef);
        assertEq(payroll.getPayroll(id).dataReference, dataRef);
        vm.stopPrank();
    }

    // /////////////////////////////////////////
    // //////// closePayroll Tests ////////////
    // ////////////////////////////////////////

    function test_closePayrollRevertsWith_OnlyOwner() public {
        Payroll payroll = new Payroll();
        payroll.initialize();
        payroll.grantOwnerRole(msg.sender);
        bytes32 id = bytes32("id");
        vm.expectRevert(abi.encodeWithSelector(Payroll.Payroll__AccessControl__CallerIsNotOwnerRole.selector, USER));
        vm.startPrank(USER);
        payroll.closePayroll(id);
        vm.stopPrank();
    }

    function test_closePayroll_should_revert_with_PayrolNotFound() public {
        vm.startPrank(msg.sender);
        Payroll payroll = new Payroll();
        payroll.initialize();
        payroll.grantOwnerRole(msg.sender);
        vm.expectRevert(Payroll.Payroll__NotFound.selector);
        payroll.closePayroll(bytes32("id"));
        vm.stopPrank();
    }

    function test_closePayroll_should_revert_with_PayrollIsClosed() public {
        vm.startPrank(msg.sender);
        Payroll payroll = new Payroll();
        payroll.initialize();
        payroll.grantOwnerRole(msg.sender);
        bytes32 id = bytes32("1");
        payroll.addPayroll(
            block.timestamp,
            block.timestamp,
            1,
            bytes32("name"),
            bytes32("payroll_type"),
            id,
            bytes32("payroll_identifier")
        );
        payroll.closePayroll(id);
        vm.expectRevert(Payroll.Payroll__AlreadyClosed.selector);
        payroll.closePayroll(id);
        vm.stopPrank();
    }

    function test_closePayroll_should_revert_with_PayrollDataReferenceMustNotBeEmpty() public {
        vm.startPrank(msg.sender);
        Payroll payroll = new Payroll();
        payroll.initialize();
        payroll.grantOwnerRole(msg.sender);
        bytes32 id = bytes32("1");
        payroll.addPayroll(
            block.timestamp, block.timestamp, 1, bytes32("name"), bytes32("payroll_type"), id, bytes32(0)
        );
        vm.expectRevert(Payroll.Payroll__DataReferenceMustNotBeEmpty.selector);
        payroll.closePayroll(id);
        vm.stopPrank();
    }

    function test_closePayroll_should_succeed() public {
        vm.startPrank(msg.sender);
        Payroll payroll = new Payroll();
        payroll.initialize();
        payroll.grantOwnerRole(msg.sender);
        payroll.grantReadRole(msg.sender);
        bytes32 id = bytes32("1");
        // assert payroll status is none before payroll is created
        P.PayrollData memory p = payroll.getPayroll(id);
        assertEq(uint256(p.status), uint256(P.Status.None));
        payroll.addPayroll(
            block.timestamp,
            block.timestamp,
            1,
            bytes32("name"),
            bytes32("payroll_type"),
            id,
            bytes32("payroll_identifier")
        );
        // assert payroll status is active when payroll is created but before it is closed
        p = payroll.getPayroll(id);
        assertEq(uint256(p.status), uint256(P.Status.Active));
        vm.expectEmit(true, false, false, true);
        emit PayrollClosed(id);
        payroll.closePayroll(id);
        // assert payroll status is Cloased
        p = payroll.getPayroll(id);
        assertEq(uint256(p.status), uint256(P.Status.Closed));
        vm.stopPrank();
    }

    // ///////////////////////////////////////////////////////////
    // //////// addDataReferenceAndClosePayroll Tests ////////////
    // ///////////////////////////////////////////////////////////

    function test_addDataReferenceAndClosePayroll_should_revert_with_onlyOwner() public {
        Payroll payroll = new Payroll();
        payroll.initialize();
        payroll.grantOwnerRole(msg.sender);
        bytes32 id = bytes32("id");
        vm.expectRevert(abi.encodeWithSelector(Payroll.Payroll__AccessControl__CallerIsNotOwnerRole.selector, USER));
        vm.startPrank(USER);
        payroll.addDataReferenceAndClosePayroll(id, bytes32("data_ref"));
        vm.stopPrank();
    }

    function test_addDataReferenceAndClosePayroll_should_succeed() public {
        vm.startPrank(msg.sender);
        Payroll payroll = new Payroll();
        payroll.initialize();
        payroll.grantOwnerRole(msg.sender);
        payroll.grantReadRole(msg.sender);
        bytes32 id = bytes32("1");
        // assert payroll status is none before payroll is created
        P.PayrollData memory p = payroll.getPayroll(id);
        assertEq(uint256(p.status), uint256(P.Status.None));
        payroll.addPayroll(
            block.timestamp, block.timestamp, 1, bytes32("name"), bytes32("payroll_type"), id, bytes32(0)
        );
        // assert payroll status is active when payroll is created but before it is closed
        p = payroll.getPayroll(id);
        assertEq(uint256(p.status), uint256(P.Status.Active));
        vm.expectEmit(true, false, false, true);
        emit DataReferenceAdded();
        emit PayrollClosed(id);
        payroll.addDataReferenceAndClosePayroll(id, bytes32("data_ref"));
        //assert payroll status is Cloased
        p = payroll.getPayroll(id);
        assertEq(uint256(p.status), uint256(P.Status.Closed));
        vm.stopPrank();
    }

    // ///////////////////////////////////////
    // //////// getPayroll Tests ////////////
    // //////////////////////////////////////

    function test_getPayrolls_reverts_with_OnlyOwner() public {
        Payroll payroll = new Payroll();
        payroll.initialize();
        vm.expectRevert(abi.encodeWithSelector(Payroll.Payroll__AccessControl__CallerIsNotReadRole.selector, USER));
        vm.startPrank(USER);
        payroll.getPayroll(bytes32(0));
        vm.stopPrank();
    }

    function test_getPayroll_Succeds() public {
        vm.startPrank(msg.sender);
        Payroll payroll = new Payroll();
        payroll.initialize();
        payroll.grantOwnerRole(msg.sender);
        payroll.grantReadRole(msg.sender);
        bytes32 id = bytes32("id2");
        payroll.addPayroll(
            block.timestamp, block.timestamp, 1, bytes32("name"), bytes32("payroll_type"), id, bytes32("ref")
        );
        P.PayrollData memory p = payroll.getPayroll(id);
        assertEq(uint256(p.status), uint256(P.Status.Active));
        vm.stopPrank();
    }

    // /////////////////////////////////////////
    // //////// getPayrollIds Tests ////////////
    // /////////////////////////////////////////

    function test_getPayrollIds_reverts_with_OnlyOwner() public {
        Payroll payroll = new Payroll();
        payroll.initialize();
        vm.expectRevert(abi.encodeWithSelector(Payroll.Payroll__AccessControl__CallerIsNotReadRole.selector, USER));
        vm.startPrank(USER);
        payroll.getPayrollIds();
        vm.stopPrank();
    }

    function test_getPayrollIds_Succeds() public {
        vm.startPrank(msg.sender);
        Payroll payroll = new Payroll();
        payroll.initialize();
        payroll.grantOwnerRole(msg.sender);
        payroll.grantReadRole(msg.sender);
        bytes32 id = bytes32("id2");
        payroll.addPayroll(
            block.timestamp, block.timestamp, 1, bytes32("name"), bytes32("payroll_type"), id, bytes32("ref")
        );
        bytes32[] memory ids = payroll.getPayrollIds();
        assertEq(ids[0], id);
        vm.stopPrank();
    }

    // /////////////////////////////////////////
    // //////// getPayrollIds Tests ////////////
    // /////////////////////////////////////////

    function test_getPayrollDataReferences_reverts_with_OnlyOwner() public {
        Payroll payroll = new Payroll();
        payroll.initialize();
        vm.expectRevert(abi.encodeWithSelector(Payroll.Payroll__AccessControl__CallerIsNotReadRole.selector, USER));
        vm.startPrank(USER);
        payroll.getPayrollDataReferences();
        vm.stopPrank();
    }

    function test_getPayrollDataReferences_Succeds() public {
        vm.startPrank(msg.sender);
        Payroll payroll = new Payroll();
        payroll.initialize();
        payroll.grantOwnerRole(msg.sender);
        payroll.grantReadRole(msg.sender);
        bytes32 id = bytes32("id2");
        bytes32 ref = bytes32("ref");
        payroll.addPayroll(block.timestamp, block.timestamp, 1, bytes32("name"), bytes32("payroll_type"), id, ref);
        bytes32[] memory ids = payroll.getPayrollDataReferences();
        assertEq(ids[0], ref);
        vm.stopPrank();
    }
}
