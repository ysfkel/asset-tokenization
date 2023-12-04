// SPDX-FileCopyrightText: (c) Copyright 2023 PaperTale Technologies, all rights reserved.
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import {Employee} from "../src/employee/Employee.sol";
import {Gender} from "../src/employee/Employee.sol";
import {EmployeeProxy} from "../src/employee/EmployeeProxy.sol";
import {EmployeeBeacon} from "../src/employee/EmployeeBeacon.sol";
/**
 * @title AssetTest
 * @author Yusuf
 * @notice Tests for Asset contract
 */

contract AssetTest is Test {
    address USER1 = makeAddr("TEST_USER_1");
    address USER2 = makeAddr("TEST_USER_2");
    address implementation;
    Employee employee;
 
    function setUp() public {
        vm.startPrank(msg.sender);
        implementation = address(new Employee());
        address _beacon = address(new EmployeeBeacon(implementation));
        bytes memory data = abi.encodeCall(Employee.initialize, ());
        address proxy = address(new EmployeeProxy(_beacon, data));
        employee = Employee(proxy);
        employee.grantOwnerRole(msg.sender);
        vm.stopPrank();
    }

    // ////////////////////////////////////
    // /////     Constructor Tests    /////
    // ////////////////////////////////////

    function test_deploy_succeeds() public {
        vm.startPrank(msg.sender);
        vm.stopPrank();
    }

    function test_add_1_succeeds() public {
        vm.startPrank(msg.sender);
        employee.addEmployee(USER1, bytes32(0), 1, 2, true);
        // employee.verifyGender(Gender(uint256(0)));
        vm.stopPrank();
    }


}

 