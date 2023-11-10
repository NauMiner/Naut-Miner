// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/InvitationCenter.sol";

contract Scripts is Script {
    InvitationCenter ic;

    function setUp() public {
        ic = new InvitationCenter();
    }

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        setUp();
        console.log("Manager address:", address(ic));
        vm.stopBroadcast();
    }
}
