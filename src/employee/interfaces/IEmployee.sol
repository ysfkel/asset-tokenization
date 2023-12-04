// SPDX-FileCopyrightText: (c) Copyright 2023 PaperTale Technologies, all rights reserved.
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {EmployeeType} from "../libraries/types.sol";
/**
 * @title Employee
 * @author Yusuf
 * @notice specification for Employee funtionality
 */

interface IEmployee {
  
    /**
     * @notice grants admin role to account
     * @param account to be granted admin role
     */
    function grantAdminRole(address account) external;

    /**
     * @notice revokes admin role from account
     * @param account to be revoked
     */
    function revokeAdminRole(address account) external;

    /**
     * @notice grants owner role to account
     * @param account to be granted admin role
     */
    function grantOwnerRole(address account) external;

    /**
     * @notice revokes owner role from account
     * @param account to be revoked
     */
    function revokeOwnerRole(address account) external;

    /**
     * @notice grants read role to account
     * @param account to be granted read role
     */
    function grantReadRole(address account) external;

    /**
     * @notice revokes read role from account
     * @param account to be revoked
     */
    function revokeReadRole(address account) external;

}
