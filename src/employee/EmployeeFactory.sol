// SPDX-FileCopyrightText: (c) Copyright 2023 PaperTale Technologies, all rights reserved.
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "@openzeppelin/access/Ownable.sol";
import "@openzeppelin/utils/Address.sol";
import {IEmployeeFactory} from "./interfaces/IEmployeeFactory.sol";
import {EmployeeProxy} from "./EmployeeProxy.sol";
import {Employee} from "./Employee.sol";

/**
 * @title EmployeeFactory
 * @author Yusuf
 * @notice deploys instances of Employee contract
 */
contract EmployeeFactory is IEmployeeFactory, Ownable {
    ////////////////////////////////////
    /////          ERRORS          /////
    ////////////////////////////////////

    error EmployeeFactory__NotContractAddress();
    error EmployeeFactory__ZeroAddress(address account);

    ////////////////////////////////////
    /////          EVENTS          /////
    ////////////////////////////////////

    event Create(address indexed _proxy);
    event SetBeacon(address _beacon);

    ////////////////////////////////////
    /////       State Variables    /////
    ////////////////////////////////////
    address private _beacon;
    mapping(address => address[]) private proxies;

    ////////////////////////////////////
    /////          Functions       /////
    ////////////////////////////////////
    constructor(address i_beacon) Ownable() {
        if (Address.isContract(i_beacon) == false) {
            revert EmployeeFactory__NotContractAddress();
        }
        _beacon = i_beacon;
    }

    ////////////////////////////////////
    /////     External Functions   /////
    ////////////////////////////////////

    /// @inheritdoc IEmployeeFactory
    function create(address owner, address admin) external onlyOwner returns (address employeeContractAddress) {
        if (owner == address(0)) {
            revert EmployeeFactory__ZeroAddress(owner);
        }
        if (admin == address(0)) {
            revert EmployeeFactory__ZeroAddress(admin);
        }
        return _create(owner, admin);
    }

    /// @inheritdoc IEmployeeFactory
    function setBeacon(address _newBeacon) external onlyOwner {
        if (Address.isContract(_newBeacon) == false) {
            revert EmployeeFactory__NotContractAddress();
        }
        _beacon = _newBeacon;
        emit SetBeacon(_beacon);
    }

    ////////////////////////////////////
    /////  External View Functions /////
    ////////////////////////////////////

    /// @inheritdoc IEmployeeFactory
    function getProxyList(address _owner) external view returns (address[] memory) {
        return proxies[_owner];
    }

    ////////////////////////////////////
    ////////  Private Functions ////////
    ////////////////////////////////////

    function _create(address owner, address admin) private returns (address) {
        EmployeeProxy _proxy = new EmployeeProxy(_beacon, "");
        Employee emp = Employee(address(_proxy));
        emp.initialize();
        emp.grantOwnerRole(owner);
        emp.grantReadRole(owner);
        emp.grantAdminRole(admin);
        emp.grantRole(emp.DEFAULT_READ_ROLE(), msg.sender);
        proxies[owner].push(address(_proxy));
        emp.revokeAdminRole(address(this));
        emit Create(address(_proxy));
        return address(_proxy);
    }
}
