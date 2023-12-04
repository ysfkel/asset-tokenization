// SPDX-FileCopyrightText: (c) Copyright 2023 PaperTale Technologies, all rights reserved.
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

/**
 * @title IEmployeeFactory
 * @author Yusuf
 * @notice specification for Employee factory
 */
interface IEmployeeFactory {
    /**
     * @notice This function should only be called by owner of the factory contract (paper tail). deploys payroll proxy and transfers ownership to payrollOwner
     * @param owner address of the owner
     * @param admin address of administrator
     * @return payrollAddress the address of the deployed payrol proxy
     */
    function create(address owner, address admin) external returns (address payrollAddress);

    /**
     * @notice sets address of the beacon contract for the proxy
     * @param newPayrollBeaconAddress beacon contract address
     */
    function setBeacon(address newPayrollBeaconAddress) external;

    /**
     * @notice returns list of payroll proxy address  for the specified address
     * @param _owner address of payrolls owner
     */
    function getProxyList(address _owner) external view returns (address[] memory);
}
