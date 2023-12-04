// SPDX-FileCopyrightText: (c) Copyright 2023 PaperTale Technologies, all rights reserved.
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {AccessControlUpgradeable} from "@openzeppelin-upgradeable/access/AccessControlUpgradeable.sol";
import {PayrollDataTypes as P} from "./libraries/PayrollDataTypes.sol";
import {IPayroll} from "./interfaces/IPayroll.sol";
import {Initializable} from "@openzeppelin-upgradeable/proxy/utils/Initializable.sol";
/**
 * @title Payrol
 * @author Yusuf
 * @notice This is a upgradeable smart contract and implements Initializable
 * ensure to execute the initialize function after contract deployment to prevent thrid party from executing this and taking ownersip of the smart contract
 */

contract Payroll is Initializable, AccessControlUpgradeable, IPayroll {
    //////////////////////////////
    /////  Errors            /////
    //////////////////////////////

    error Payroll__AlreadyExists();
    error Payroll__NotFound();
    error Payroll__InvalidID();
    error Payroll__DataReferenceMustNotBeEmpty();
    error Payroll__AlreadyClosed();
    error Payroll__DefaultReadRoleCannotBeRevoked();
    error Payroll__AccessControl__CallerIsNotAdminRole(address caller);
    error Payroll__AccessControl__CallerIsNotOwnerRole(address caller);
    error Payroll__AccessControl__CallerIsNotReadRole(address caller);

    //////////////////////////////
    /////  Events            /////
    //////////////////////////////

    event PayrollAdded(bytes32 indexed id, uint256 publishDate);
    event PayrollClosed(bytes32 indexed id);
    event DataReferenceAdded();

    //////////////////////////////
    /////  constants         /////
    //////////////////////////////

    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");
    bytes32 public constant READ_ROLE = keccak256("READ_ROLE");
    bytes32 public constant DEFAULT_READ_ROLE = keccak256("DEFAULT_READ_ROLE");

    //////////////////////////////
    /////  State variables   /////
    //////////////////////////////

    bytes32[] private ids;
    bytes32[] private payrolDataReferences;
    mapping(bytes32 => P.PayrollData) private payrolls;

    ///////////////////////////////////////
    //////////////  Modifiers /////////////
    ///////////////////////////////////////

    modifier onlyAdmin() {
        if (hasRole(DEFAULT_ADMIN_ROLE, _msgSender()) == false) {
            revert Payroll__AccessControl__CallerIsNotAdminRole(_msgSender());
        }
        _;
    }

    modifier onlyOwner() {
        if (hasRole(OWNER_ROLE, _msgSender()) == false) {
            revert Payroll__AccessControl__CallerIsNotOwnerRole(_msgSender());
        }
        _;
    }

    modifier onlyReadRole() {
        if (hasRole(READ_ROLE, _msgSender()) == false && hasRole(DEFAULT_READ_ROLE, _msgSender()) == false) {
            revert Payroll__AccessControl__CallerIsNotReadRole(_msgSender());
        }
        _;
    }

    ///////////////////////////////////////
    /////////////// Functions /////////////
    ///////////////////////////////////////

    /**
     * @notice initializes the contracts . Must be called after proxy creation
     */
    function initialize() external initializer {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    ///////////////////////////////////////
    /////  Externa & Public Functions /////
    ///////////////////////////////////////

    /// @inheritdoc IPayroll
    function addPayroll(
        uint256 startDate,
        uint256 endDate,
        uint256 revision,
        bytes32 name,
        bytes32 payrollType,
        bytes32 id,
        bytes32 dataReference
    ) external onlyOwner {
        _addPayroll(startDate, endDate, revision, name, payrollType, id, dataReference);
    }

    /// @inheritdoc IPayroll
    function addPayrollAndClosePayroll(
        uint256 startDate,
        uint256 endDate,
        uint256 revision,
        bytes32 name,
        bytes32 payrollType,
        bytes32 id,
        bytes32 dataReference
    ) external onlyOwner {
        if (dataReference == bytes32(0)) {
            revert Payroll__DataReferenceMustNotBeEmpty();
        }
        _addPayroll(startDate, endDate, revision, name, payrollType, id, dataReference);
        _closePayroll(id);
    }

    /// @inheritdoc IPayroll
    function addDatareference(bytes32 id, bytes32 dataReference) external onlyOwner {
        _addDatareference(id, dataReference);
    }

    /// @inheritdoc IPayroll
    function closePayroll(bytes32 id) external onlyOwner {
        _closePayroll(id);
    }

    /// @inheritdoc IPayroll
    function addDataReferenceAndClosePayroll(bytes32 id, bytes32 dataReference) external onlyOwner {
        _addDatareference(id, dataReference);
        _closePayroll(id);
    }

    /////////////////////////////////////
    ///// External Funtions (Admin) /////
    /////////////////////////////////////

    /// @inheritdoc IPayroll
    function grantAdminRole(address account) external onlyAdmin {
        _grantRole(DEFAULT_ADMIN_ROLE, account);
    }

    /// @inheritdoc IPayroll
    function revokeAdminRole(address account) external onlyAdmin {
        revokeRole(DEFAULT_ADMIN_ROLE, account);
    }

    /// @inheritdoc IPayroll
    function grantOwnerRole(address account) external onlyAdmin {
        _setupRole(OWNER_ROLE, account);
    }

    /// @inheritdoc IPayroll
    function revokeOwnerRole(address account) external onlyAdmin {
        _revokeRole(OWNER_ROLE, account);
    }

    /// @inheritdoc IPayroll
    function grantReadRole(address account) external onlyAdmin {
        _grantRole(READ_ROLE, account);
    }

    /// @inheritdoc IPayroll
    function revokeReadRole(address account) external onlyAdmin {
        _revokeRole(READ_ROLE, account);
    }

    /**
     * @notice grants role to specified account
     * @dev overrides the modifier
     */
    function grantRole(bytes32 role, address account) public virtual override onlyAdmin {
        _grantRole(role, account);
    }

    /**
     * @notice revokes role from specified account except DEFAULT_READ_ROLE
     * @dev overrides the modifier
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyAdmin {
        if (role == DEFAULT_READ_ROLE) {
            revert Payroll__DefaultReadRoleCannotBeRevoked();
        }

        _revokeRole(role, account);
    }

    /////////////////////////////////////
    ////// External View Funtions ///////
    /////////////////////////////////////

    /// @inheritdoc IPayroll
    function getPayroll(bytes32 id) external view onlyReadRole returns (P.PayrollData memory) {
        return payrolls[id];
    }

    /// @inheritdoc IPayroll
    function getPayrollIds() external view onlyReadRole returns (bytes32[] memory) {
        return ids;
    }

    /// @inheritdoc IPayroll
    function getPayrollDataReferences() external view onlyReadRole returns (bytes32[] memory) {
        return payrolDataReferences;
    }

    /////////////////////////////////////
    ///////// private  Funtions /////////
    /////////////////////////////////////

    /**
     * @notice private function _addPayroll. completes addPayroll external function
     */
    function _addPayroll(
        uint256 startDate,
        uint256 endDate,
        uint256 revision,
        bytes32 name,
        bytes32 payrollType,
        bytes32 id,
        bytes32 dataReference
    ) private {
        if (id == bytes32(0)) {
            revert Payroll__InvalidID();
        }

        if (payrolls[id].status != P.Status.None) {
            revert Payroll__AlreadyExists();
        }
        uint256 _publishDate = block.timestamp;

        payrolls[id] = P.PayrollData({
            status: P.Status.Active,
            publishDate: _publishDate,
            startDate: startDate,
            endDate: endDate,
            id: id,
            revision: revision,
            name: name,
            payrollType: payrollType,
            dataReference: dataReference
        });
        ids.push(id);
        payrolDataReferences.push(dataReference);
        emit PayrollAdded(id, _publishDate);
    }

    /**
     * @notice private function _addDatareference. completes addDatareference external function
     */
    function _addDatareference(bytes32 id, bytes32 dataReference) private {
        if (payrolls[id].status == P.Status.None) {
            revert Payroll__NotFound();
        }
        if (dataReference == bytes32(0)) {
            revert Payroll__DataReferenceMustNotBeEmpty();
        }
        if (payrolls[id].status == P.Status.Closed) {
            revert Payroll__AlreadyClosed();
        }
        payrolls[id].dataReference = dataReference;
        emit DataReferenceAdded();
    }

    /**
     * @notice private function _closePayroll. completes closePayroll external function
     */
    function _closePayroll(bytes32 id) private {
        P.PayrollData memory p = payrolls[id];
        if (p.status == P.Status.None) {
            revert Payroll__NotFound();
        }
        if (p.status == P.Status.Closed) {
            revert Payroll__AlreadyClosed();
        }
        if (p.dataReference == bytes32(0)) {
            revert Payroll__DataReferenceMustNotBeEmpty();
        }
        payrolls[id].status = P.Status.Closed;
        emit PayrollClosed(id);
    }
}
