// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/FakeUSDT.sol";
import "../src/FakeZeb.sol";
import "../src/Node.sol";

contract Scripts is Script {
    FakeUSDT usdt;
    FakeZeb zeb;
    Node node;
    address receiver = address(0x02);
    uint256 signerPri = 0xAA;
    address signer = vm.addr(signerPri);
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address deployer = vm.addr(deployerPrivateKey);

    function setUp() public {
        usdt = new FakeUSDT();
        zeb = new FakeZeb();
        node = new Node("","",address(usdt), address(zeb), receiver, signer);
        usdt.mint(address(this), 10e20);
        usdt.mint(deployer, 10e20);
    }

    function mint() public {
        address inviter = address(0x4);
        uint256 discount = 1;
        uint256 time = block.timestamp;
        address user = deployer;
        Node.MachineType[] memory machaineTypes = new Node.MachineType[](1);
        machaineTypes[0] = Node.MachineType.Regular;
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 1;
        bytes32 hash = keccak256(abi.encode(inviter, discount, time, user));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPri, hash);
        v = v - 27;
        bytes memory signature = abi.encodePacked(r, s, v);
        console.logBytes(signature);
        usdt.approve(address(node), 10e50);
        node.publicMint(machaineTypes, amounts, inviter, discount, time, user, signature);
    }

    function upgrade() public {
        bool isUSDT = true;
        uint256 tokenId = 0;
        uint256 time = block.timestamp;
        address user = deployer;
        Node.EquipmentType equipmentType = Node.EquipmentType.Pipe;
        Node.EquipmentLevel equipmentLevel = Node.EquipmentLevel.Gold;
        uint256 zebPrice = 10;
        address inviter = address(0x4);
        bytes32 hash = keccak256(abi.encode(zebPrice, inviter, time, user));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPri, hash);
        v = v - 27;
        bytes memory signature = abi.encodePacked(r, s, v);
        node.upgrade(isUSDT, tokenId, equipmentType, equipmentLevel, inviter, zebPrice, time, user, signature);
    }

    function run() public {
        vm.startBroadcast(deployerPrivateKey);
        setUp();
        console.log("node contract address:", address(node));
        console.log("usdt address:", address(usdt));
        console.log("zeb address:", address(zeb));
        mint();
        upgrade();
        vm.stopBroadcast();
    }
}
