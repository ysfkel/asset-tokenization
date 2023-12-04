// SPDX-FileCopyrightText: (c) Copyright 2023 PaperTale Technologies, all rights reserved.
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {AccessControlUpgradeable} from "@openzeppelin-upgradeable/access/AccessControlUpgradeable.sol";
import {EmployeeType, Gender, AgeVerification} from "./libraries/types.sol";
import {IEmployee} from "./interfaces/IEmployee.sol";
import {Initializable} from "@openzeppelin-upgradeable/proxy/utils/Initializable.sol";
/**
 * @title Employee
 * @author Yusuf
 * @notice This is a upgradeable smart contract and implements Initializable
 * ensure to execute the initialize function after contract deployment to prevent thrid party from executing this and taking ownersip of the smart contract
 */

contract Employee is Initializable, AccessControlUpgradeable, IEmployee {
    //////////////////////////////
    /////  Errors            /////
    //////////////////////////////

    error Employee__AlreadyExists();
    error Employee__NotFound();
    error Employee__InvalidID();
    error Employee__DataReferenceMustNotBeEmpty();
    error Employee__AlreadyClosed();
    error Employee__ZeroAddress();
    error Employee__DefaultReadRoleCannotBeRevoked();
    error Employee__AccessControl__CallerIsNotAdminRole(address caller);
    error Employee__AccessControl__CallerIsNotOwnerRole(address caller);
    error Employee__AccessControl__CallerIsNotReadRole(address caller);
    error Employee__GenderAlreadyVerified();
    error Employee_GenderCannotBeVerified();
    error Employee__DateOfBirthAlreadyVerified();
    error Employee__DateOfBirthCannotBeVerified();

    //////////////////////////////
    /////  Events            /////
    //////////////////////////////

    event AddEmployee(bytes32 indexed id, EmployeeType employee);
    event VerifyGender(address sender, bytes32 employeeId, Gender gender);
    event VerifyDateOfBirth(address sender, bytes32 employeeId, uint256 dateOfBirth);
    //////////////////////////////
    /////  constants         /////
    //////////////////////////////
    uint256 public constant minAge = 568024668000;
    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");
    bytes32 public constant READ_ROLE = keccak256("READ_ROLE");
    bytes32 public constant DEFAULT_READ_ROLE = keccak256("DEFAULT_READ_ROLE");

    //////////////////////////////
    /////  State variables   /////
    //////////////////////////////

    bytes32[] private _ids;
    mapping(bytes32 employeeId => address account) private _idToAccount;
    mapping(address => EmployeeType) private _employees;
    mapping(address => bool) private _verifiedDateOfBirth;
    mapping(address => bool) private _verifiedGender;
    ///////////////////////////////////////
    //////////////  Modifiers /////////////
    ///////////////////////////////////////

    modifier onlyAdmin() {
        if (hasRole(DEFAULT_ADMIN_ROLE, _msgSender()) == false) {
            revert Employee__AccessControl__CallerIsNotAdminRole(_msgSender());
        }
        _;
    }

    modifier onlyOwner() {
        if (hasRole(OWNER_ROLE, _msgSender()) == false) {
            revert Employee__AccessControl__CallerIsNotOwnerRole(_msgSender());
        }
        _;
    }

    modifier onlyReadRole() {
        if (hasRole(READ_ROLE, _msgSender()) == false && hasRole(DEFAULT_READ_ROLE, _msgSender()) == false) {
            revert Employee__AccessControl__CallerIsNotReadRole(_msgSender());
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

    function addEmployee(address _account, bytes32 _employeeId, uint256 _gender, uint256 _dateOfBirth, bool _active)
        external
        onlyOwner
    {
        if (_account == address(0)) {
            revert Employee__ZeroAddress();
        }

        if (_employees[_account].account == _account) {
            revert Employee__AlreadyExists();
        }
        _idToAccount[_employeeId] = _account;
        _addEmployee(_account, _employeeId, _gender, _dateOfBirth, _active); //, dateOfBirthVerified, genderVerified);
    }

    function getAccount(address account) external view returns (address) {
        return _employees[account].account;
    }

    function verifyGender(Gender _gender) external  {
        if (_verifiedGender[msg.sender] == true ) {
            revert Employee__GenderAlreadyVerified();
        }
 
        if(_employees[msg.sender].gender != _gender) {
             revert Employee_GenderCannotBeVerified();
        }
         
        _verifiedGender[msg.sender] = true;
        EmployeeType memory _emp = _employees[msg.sender];

        emit VerifyGender(msg.sender, _emp.employeeId, _emp.gender);
    }

     function verifyDateOfBirth(uint256 _dateOfBirth) external {
        if (_verifiedDateOfBirth[msg.sender] == true ) {
            revert Employee__DateOfBirthAlreadyVerified();
        }
 
        if(_employees[msg.sender].dateOfBirth != _dateOfBirth) {
             revert Employee__DateOfBirthCannotBeVerified();
        }
         
        _verifiedDateOfBirth[msg.sender] = true;
        EmployeeType memory _emp = _employees[msg.sender];

        emit VerifyDateOfBirth(msg.sender, _emp.employeeId, _emp.dateOfBirth);
    }


    /////////////////////////////////////
    ///// External Funtions (Admin) /////
    /////////////////////////////////////

    /// @inheritdoc IEmployee
    function grantAdminRole(address _account) external onlyAdmin {
        _grantRole(DEFAULT_ADMIN_ROLE, _account);
    }

    /// @inheritdoc IEmployee
    function revokeAdminRole(address _account) external onlyAdmin {
        revokeRole(DEFAULT_ADMIN_ROLE, _account);
    }

    /// @inheritdoc IEmployee
    function grantOwnerRole(address _account) external onlyAdmin {
        _setupRole(OWNER_ROLE, _account);
    }

    /// @inheritdoc IEmployee
    function revokeOwnerRole(address _account) external onlyAdmin {
        _revokeRole(OWNER_ROLE, _account);
    }

    /// @inheritdoc IEmployee
    function grantReadRole(address _account) external onlyAdmin {
        _grantRole(READ_ROLE, _account);
    }

    /// @inheritdoc IEmployee
    function revokeReadRole(address _account) external onlyAdmin {
        _revokeRole(READ_ROLE, _account);
    }

    /**
     * @notice grants role to specified account
     * @dev overrides the modifier
     */
    function grantRole(bytes32 role, address _account) public virtual override onlyAdmin {
        _grantRole(role, _account);
    }

    /**
     * @notice revokes role from specified account except DEFAULT_READ_ROLE
     * @dev overrides the modifier
     */
    function revokeRole(bytes32 role, address _account) public virtual override onlyAdmin {
        if (role == DEFAULT_READ_ROLE) {
            revert Employee__DefaultReadRoleCannotBeRevoked();
        }

        _revokeRole(role, _account);
    }

    // /////////////////////////////////////
    // ////// External View Funtions ///////
    // /////////////////////////////////////


    // /////////////////////////////////////
    // ///////// private  Funtions /////////
    // /////////////////////////////////////
    /**
     * @notice private function addEmployee. completes addEmployee external function
     */
    function _addEmployee(address _account, bytes32 _employeeId, uint256 _gender, uint256 _dateOfBirth, bool _active)
        private
    {
        EmployeeType memory emp = EmployeeType({
            account: _account,
            employeeId: _employeeId,
            gender: Gender(_gender),
            dateOfBirth: _dateOfBirth,
            active: _active,
            ageVerification: AgeVerification.Unverified
        });

        _employees[_account] = emp;

        _ids.push(_employeeId);
        emit AddEmployee(_employeeId, emp);
    }

 
}
