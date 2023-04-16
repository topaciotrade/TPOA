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



### Disclaimer
Because everyone is free to deploy his own contract, any deployment is at your own risk, he cannot promise any guarantee. While we strive to develop correctly, it is impossible to ensure that everything published is sound. If you're unsure about particular content, feel free to raise your concerns on the appropriate talk page.

Nothing in the TPOA should be construed as legal advice or financial advice. If you need legal advice, please contact a lawyer.

By contributing to any development, you agree to assign a copyright for your contribution to the Free Software Foundation. The Free Software Foundation promises always to use either a verbatim copying license or a free documentation license when publishing your contribution. We grant you back all your rights under copyright, including the rights to copy, modify, and redistribute your contributions.
