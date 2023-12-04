// SPDX-FileCopyrightText: (c) Copyright 2023 PaperTale Technologies, all rights reserved.
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {Test, Vm} from "forge-std/Test.sol";
import {Deploy} from "../script/payroll/Deploy.s.sol";
import {PayrollProxy} from "../src/payroll/PayrollProxy.sol";
import {PayrollFactory} from "../src/payroll/PayrollFactory.sol";
import {Payroll} from "../src/payroll/Payroll.sol";
import {PayrollDataTypes as P} from "../src/payroll/libraries/PayrollDataTypes.sol";

/**
 * @title PayrollFactoryTest
 * @author Yusuf
 * @notice Tests for PayrollFactory contract
 */
contract PayrollFactoryTest is Test {
    Deploy deployer;
    address payrollImplAddress;
    address payrollBeacon;
    address payrollFactory;
    address USER = makeAddr("TEST_USER");
    address SOME_CONTRACT_ADDRESS = makeAddr("SOME_CONTRACT_ADDRESS");

    event PayrollCreated(address indexed payrollProxy);
    event PayrollAdded(bytes32 indexed id, uint256 publishDate);

    function setUp() public {
        deployer = new Deploy();
        (payrollImplAddress, payrollBeacon, payrollFactory) = deployer.run();
    }

    ////////////////////////////////////
    /////     Constructor Tests    /////
    ////////////////////////////////////

    function test_constructor_reverts_with_NotContractAddress() public {
        vm.startPrank(msg.sender);
        vm.expectRevert(PayrollFactory.PayrollFactory__NotContractAddress.selector);
        new PayrollFactory(USER);
        vm.stopPrank();
    }

    function test_constructor_arguments_are_set() public {
        vm.startPrank(msg.sender);
        PayrollFactory factory = new PayrollFactory(payrollBeacon);
        assertEq(factory.payrollBeacon(), payrollBeacon);
        vm.stopPrank();
    }

    ////////////////////////////////////
    /////   createPayroll Tests    /////
    ////////////////////////////////////

    function test_createPayroll_succeeds() public {
        vm.startPrank(msg.sender);
        PayrollFactory factory = new PayrollFactory(payrollBeacon);
        vm.expectEmit(false, false, false, false);
        emit PayrollCreated(payrollBeacon);
        address payrollProxy = factory.createPayroll(msg.sender, USER);
        address[] memory pl = factory.getPayrollList(msg.sender);
        assertEq(pl[0], payrollProxy);
        vm.stopPrank();
    }

    ////////////////////////////////////
    /////   setBeacon Tests        /////
    ////////////////////////////////////

    function test_setBeacon_reverts_with_onlyOwner() public {
        PayrollFactory factory = new PayrollFactory(payrollBeacon);
        vm.startPrank(USER);
        vm.expectRevert("Ownable: caller is not the owner");
        factory.setBeacon(payrollBeacon);
        vm.stopPrank();
    }

    function test_setBeacon_reverts_with_NotContractAddressr() public {
        vm.startPrank(msg.sender);
        PayrollFactory factory = new PayrollFactory(payrollBeacon);
        vm.expectRevert(PayrollFactory.PayrollFactory__NotContractAddress.selector);
        factory.setBeacon(msg.sender);
        vm.stopPrank();
    }

    function test_setBeacon_succeeds() public {
        vm.startPrank(msg.sender);
        PayrollFactory factory = new PayrollFactory(payrollBeacon);
        address fakeBeaconAddress = payrollImplAddress;
        factory.setBeacon(fakeBeaconAddress);
        assertEq(factory.payrollBeacon(), fakeBeaconAddress);
        vm.stopPrank();
    }

    ////////////////////////////////////
    /////   getPayrollList Tests   /////
    ////////////////////////////////////

    function test_getPayrollList_succeeds() public {
        vm.startPrank(msg.sender);
        PayrollFactory factory = new PayrollFactory(payrollBeacon);
        address payrollProxy = factory.createPayroll(msg.sender, USER);
        address[] memory pl = factory.getPayrollList(msg.sender);
        assertEq(pl[0], payrollProxy);
        vm.stopPrank();
    }
}
