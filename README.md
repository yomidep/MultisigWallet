## Documentation

**What is multisig wallet ?** 

A multisig wallet (also known as multi signature wallet or shared wallet) is **a cryptocurrency wallet that requires two or more signatures to confirm and send a transaction**.

**Main features:**

The major features of the contract include;

1. **SubmitTransaction:** The user submits a transaction for confirmation from the owners of the wallet, then the execution function is called. 
2. **ConfirmTransaction:** The owners of the wallet confirm their transactions with this function. Once the confirmation has reached the minimum then the execution would take place.
3. **executeTransaction:** This function is called when the transaction has been confirmed by all owners. Once this function is called, it is executed and sent to the blockchain.
4. **revokeTransaction:** This function is called by one of the owners or all of them. This is done when an unauthorised transaction is submitted.

**Contract Architecture:** 

- The contract makes use of inheritance to inherit from reentrancy guard contract to protect against reentrancy attacks.
- The contract makes use of state variables in owners, confirmation requirements, transactions, and confirmation mapping .
- The contract also made use of modifiers for access control, transaction validation, signature validation.
- This contract follows a modular structure with clear separation of concerns. It is a flexible multi Sig wallet with multiple functionality.

**Transaction Flow**

1. The user enters the details of the transaction then submits it 
2. The owners then confirms the transaction 
3. One of the owners then call the execute transaction function.

## **Here’s the link to interact with the contract;**

https://goerli.basescan.org/address/0x1c3e1d4eda528ca00958c54e3b9eed8b223db8e9#code

## Here’s the link to the github repo;

https://github.com/yomidep/MultisigWallet