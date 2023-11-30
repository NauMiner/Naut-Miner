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
        usdt.mint(address(node), 10e20);
    }

    function mint() public {
        address inviter = address(0x4);
        uint256 discount = 1;
        bytes32 hash = keccak256(abi.encode(inviter, discount));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPri, hash);
        v = v - 27;
        bytes memory signature = abi.encodePacked(r, s, v);
        Node.MachineType[] memory machaineTypes = new Node.MachineType[](1);
        machaineTypes[0] = Node.MachineType.Regular;
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 1;
        node.publicMint(machaineTypes, amounts, inviter, discount, signature);
    }

    function upgrade() public {
        bool isUSDT = true;
        uint256 tokenId = 0;
        Node.EquipmentType equipmentType = Node.EquipmentType.Pipe;
        Node.EquipmentLevel equipmentLevel = Node.EquipmentLevel.Gold;
        uint256 zebPrice = 10;
        bytes32 hash = keccak256(abi.encode(zebPrice));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPri, hash);
        v = v - 27;
        bytes memory signature = abi.encodePacked(r, s, v);
        node.upgrade(isUSDT, tokenId, equipmentType, equipmentLevel, zebPrice, signature);
    }

    function run() public {
        vm.startBroadcast(deployerPrivateKey);
        setUp();
        console.log("node contract address:", address(node));
        mint();
        upgrade();
        vm.stopBroadcast();
    }
}
