// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract multiSig is ReentrancyGuard {
    event Deposit(address indexed sender, uint amount, uint balance);
    event SubmitTransaction(
        address indexed owner,
        uint indexed txIndex,
        address indexed to,
        uint value,
        bytes data
    );
    event ConfirmTransaction(address indexed owner, uint indexed txIndex);
    event revokeConfirmatioN(address indexed owner, uint indexed txIndex);
    event executeTransactioN(address indexed owner, uint indexed txIndex);

    address[] public owners;
    mapping(address => bool) public isOwner;
    uint public confirmationsRequired;

    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool executed;
        uint confirmationNo; 
    }

    mapping(uint => mapping(address => bool)) public confirmeD;

    Transaction[] public transactions;

    modifier onlyOwner()  {
        require(isOwner[msg.sender], "ole, give it to the owner man");
        _;
    }

    modifier txReal(uint _txIndex) {
        require(_txIndex < transactions.length, "tx not real");
        _;
    }

    modifier notExecuted(uint _txIndex) {
        require(!transactions[_txIndex].executed, "blud's been executed man");
        _;
    }

    modifier notConfirmed(uint _txIndex) {
        require(!confirmeD[_txIndex][msg.sender], "blud's been executed");
        _;
    }

    modifier validSignature(uint _txIndex, bytes memory _signature) {
        require(_txIndex < transactions.length, "Transaction does not exist");
        Transaction storage transaction = transactions[_txIndex];
        bytes32 hash = keccak256(abi.encodePacked(address(this), _txIndex, transaction.to,
        transaction.value, transaction.data));

        address signer = ECDSA.recover(hash, _signature);
        require(signer != address(0) && isOwner[signer], "Invalid Signature, Immposter");
        _;
    }


    constructor(address[] memory _owners, uint _confirmationsRequired) {
        require(_owners.length > 0, "owners needed");
        require(
            _confirmationsRequired > 0 &&
              _confirmationsRequired <= _owners.length,
              "Not enough owners"
        );

        for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];

            require(owner != address(0), "wrong owner");
            require(!isOwner[owner], "fraud");

            isOwner[owner] = true;
            owners.push(owner);
        }

        confirmationsRequired = _confirmationsRequired;  
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    function submitTransaction(
        address _to,
        uint _value,
        bytes memory _data
    ) public onlyOwner {
        uint txIndex = transactions.length;

        transactions.push(
            Transaction({
                to: _to,
                value: _value,
                data: _data,
                executed: false,
                confirmationNo: 0
            })
        );

        emit SubmitTransaction(msg.sender, txIndex, _to, _value, _data);
    }

    function confirmTransaction(
        uint _txIndex
    ) public onlyOwner txReal(_txIndex) notExecuted(_txIndex) notConfirmed(_txIndex) {
        Transaction storage transaction = transactions[_txIndex];
        transaction.confirmationNo += 1;
        confirmeD[_txIndex][msg.sender] = true;

        emit ConfirmTransaction(msg.sender, _txIndex);
    }

    function executeTransaction(uint _txIndex, bytes memory _signature) public onlyOwner txReal(_txIndex) notExecuted(_txIndex) validSignature(_txIndex, _signature) {
        Transaction storage transaction = transactions[_txIndex];

        require(
            transaction.confirmationNo >= confirmationsRequired,
            "Impossible"
        );

        transaction.executed = true;

        (bool success,) = transaction.to.call{value: transaction.value}(
            transaction.data
        );

        require(success, "tx failed");

        emit executeTransactioN(msg.sender, _txIndex);
    }

    function revokeConfirmation(uint _txIndex) public onlyOwner txReal(_txIndex) notExecuted(_txIndex) {
        Transaction storage transaction = transactions[_txIndex];

        require(confirmeD[_txIndex][msg.sender], " tx is not confirmed");

        transaction.confirmationNo -= 1;
        confirmeD[_txIndex][msg.sender] = false;

        emit revokeConfirmatioN(msg.sender, _txIndex);
    }

    function getOwners() public view returns (address[] memory) {
        return owners;
    }

    function getTransactionC() public view returns (uint) {
        return transactions.length;
    }

    function getTransaction(uint _txIndex) public view returns (address to,
    uint value,
    bytes memory data,
    bool executed,
    uint confirmationNo)
    {
        Transaction storage transaction =  transactions[_txIndex];

        return(
            transaction.to,
            transaction.value,
            transaction.data,
            transaction.executed,
            transaction.confirmationNo
        );
    }
         function withdraw(address payable receiver, uint amount) public onlyOwner  nonReentrant {
            require(receiver != address(0), "Invalid receiver address");
        require(amount > 0, "Invalid amount");

        uint txIndex = transactions.length;

        transactions.push(
            Transaction({
                to: receiver,
                value: amount,
                data: "",
                executed: false,
                confirmationNo: 0
            })
        );

        emit SubmitTransaction(msg.sender, txIndex, receiver, amount, "");

        confirmTransaction(txIndex);
        executeTransaction(txIndex, new bytes(0));
         }

}
