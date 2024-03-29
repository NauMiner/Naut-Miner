// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract FakeZeb is ERC20 {
    constructor() ERC20("USDT", "USDT") {
        _mint(msg.sender, 100000000);
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    function decimals() public pure override returns (uint8) {
        return 9;
    }
}
