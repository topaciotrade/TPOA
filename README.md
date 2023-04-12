# TPOA
Tpoa Alternative Open Source to (Proof of Attendance Protocol) POAP

- Implementations of standards of OpenZeppelin contract

- Reusable Solidity components to build custom contracts and complex decentralized systems.

- Scale your decentralized application, transparency and with on-chain data.


```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import "tpoa/contracts/TPOA.sol";

// extend AdministratorTPoa & pass Name Collection and some Symbol
contract MyCollectibleTPOA is AdministratorTPoa("MyCustomTPoa", "MTPOA") {

    // add custom methods
    function crearTpoa(
        string memory __uri_hash_meta,
        string memory __hash_img,
        uint256 __minutes_active
    ) public payable {
        addNewTPoa(__uri_hash_meta, __hash_img, __minutes_active);
    }

}

```
