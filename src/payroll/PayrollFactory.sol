// SPDX-FileCopyrightText: (c) Copyright 2023 PaperTale Technologies, all rights reserved.
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "@openzeppelin/access/Ownable.sol";
import "@openzeppelin/utils/Address.sol";
import {IPayrollFactory} from "./interfaces/IPayrollFactory.sol";
import {PayrollProxy} from "./PayrollProxy.sol";
import {Payroll} from "./Payroll.sol";

/**
 * @title PayrollFactory
 * @author Yusuf
 * @notice deploys instances of Payroll contract
 */
contract PayrollFactory is IPayrollFactory, Ownable {
    ////////////////////////////////////
    /////          ERRORS          /////
    ////////////////////////////////////

    error PayrollFactory__NotContractAddress();
    error PayrollFactory__ZeroAddress(address account);

    ////////////////////////////////////
    /////          EVENTS          /////
    ////////////////////////////////////

    event PayrollCreated(address indexed payrollAddress);
    event PayrollBeaconAddressUpdated(address newPayrollBeaconAddress);

    ////////////////////////////////////
    /////       State Variables    /////
    ////////////////////////////////////
    address public payrollBeacon;
    mapping(address => address[]) public payrolls;

    ////////////////////////////////////
    /////          Functions       /////
    ////////////////////////////////////
    constructor(address _payrollBeacon) Ownable() {
        if (Address.isContract(_payrollBeacon) == false) {
            revert PayrollFactory__NotContractAddress();
        }
        payrollBeacon = _payrollBeacon;
    }

    ////////////////////////////////////
    /////     External Functions   /////
    ////////////////////////////////////

    /// @inheritdoc IPayrollFactory
    function createPayroll(address owner, address admin) external onlyOwner returns (address payrollAddress) {
        if (owner == address(0)) {
            revert PayrollFactory__ZeroAddress(owner);
        }
        if (admin == address(0)) {
            revert PayrollFactory__ZeroAddress(admin);
        }
        return _createPayroll(owner, admin);
    }

    /// @inheritdoc IPayrollFactory
    function setBeacon(address newPayrollBeaconAddress) external onlyOwner {
        if (Address.isContract(newPayrollBeaconAddress) == false) {
            revert PayrollFactory__NotContractAddress();
        }
        payrollBeacon = newPayrollBeaconAddress;
        emit PayrollBeaconAddressUpdated(newPayrollBeaconAddress);
    }

    ////////////////////////////////////
    /////  External View Functions /////
    ////////////////////////////////////

    /// @inheritdoc IPayrollFactory
    function getPayrollList(address payrollOwner) external view returns (address[] memory) {
        return payrolls[payrollOwner];
    }

    ////////////////////////////////////
    ////////  Private Functions ////////
    ////////////////////////////////////

    function _createPayroll(address owner, address admin) private returns (address payrollAddress) {
        PayrollProxy payrollProxy = new PayrollProxy(payrollBeacon);
        Payroll payroll = Payroll(address(payrollProxy));
        payroll.initialize();
        payroll.grantOwnerRole(owner);
        payroll.grantReadRole(owner);
        payroll.grantAdminRole(admin);
        payroll.grantRole(payroll.DEFAULT_READ_ROLE(), msg.sender);
        payrolls[owner].push(address(payrollProxy));
        payroll.revokeAdminRole(address(this));
        emit PayrollCreated(address(payrollProxy));
        return address(payrollProxy);
    }
}
