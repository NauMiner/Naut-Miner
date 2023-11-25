// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "./InvitationCenter.sol";

contract Node is ERC721, Ownable {
    using SafeERC20 for IERC20;

    enum MachaineType {
        Regular,
        Enhenced,
        Finest
    }

    enum EquipmentLevel {
        Base,
        Gold,
        Platinum,
        Diamond
    }

    enum EquipmentType {
        Pipe,
        Gear,
        Grill
    }

    struct NodeInfo {
        MachaineType machaineType;
        EquipmentType[] equipmentType;
        mapping(EquipmentType => EquipmentLevel) equipmentLevel;
        uint256 mintTime;
        uint256 unlockPeriod;
        uint256 totalToken;
    }

    bool public isPromotion;
    bool public transferable;
    uint256 public nextTokenID;
    mapping(uint256 => NodeInfo) public nodeInfo;
    IERC20 public USDT;
    InvitationCenter public invitationCenter;
    address public receiver;

    modifier onlyTransferable() {
        require(transferable, "NFT: not transferable");
        _;
    }

    constructor(string memory name, string memory symbol) ERC721(name, symbol) Ownable(msg.sender) {}

    function publicMint(MachaineType[] memory _machineType, uint256[] memory amount, bytes32 inviterCode) public {
        for (uint256 i = 0; i < _machineType.length; i++) {
            mint(_machineType[i], amount[i], inviterCode);
        }
    }

    function mint(MachaineType _machaineType, uint256 amount, bytes32 inviterCode) internal {
        address inviter;
        uint256 totalToken;
        if (inviterCode == bytes32(0)) {
            invitationCenter.registerInviterAuth(
                msg.sender, hex"4D415853314B5337000000000000000000000000000000000000000000000000"
            );
            inviter = invitationCenter.inviterCodeToAddress(
                hex"4D415853314B5337000000000000000000000000000000000000000000000000"
            );
        } else {
            invitationCenter.registerInviterAuth(msg.sender, inviterCode);
            inviter = invitationCenter.inviterCodeToAddress(inviterCode);
        }
        if (_machaineType == MachaineType.Regular) {
            USDT.transfer(receiver, 500 * 10e18 * amount * 95 / 100);
            USDT.transfer(inviter, 500 * 10e18 * amount * 5 / 100);
            totalToken = 1200;
        }
        if (_machaineType == MachaineType.Enhenced) {
            USDT.transfer(receiver, 800 * 10e18 * amount * 95 / 100);
            USDT.transfer(inviter, 800 * 10e18 * amount * 5 / 100);
            totalToken = 2000;
        }
        if (_machaineType == MachaineType.Finest) {
            USDT.transfer(receiver, 1200 * 10e18 * amount * 95 / 100);
            USDT.transfer(inviter, 1200 * 10e18 * amount * 5 / 100);
            totalToken = 3200;
        }
        for (uint256 i = 0; i < amount; i++) {
            uint256 tokenId = nextTokenID;
            nextTokenID++;
            _mint(msg.sender, tokenId);
            nodeInfo[tokenId].machaineType = _machaineType;
            nodeInfo[tokenId].mintTime = block.timestamp;
            nodeInfo[tokenId].unlockPeriod = 1440 days;
            nodeInfo[tokenId].totalToken = totalToken;
        }
    }

    function upgrade(uint256 tokenId, EquipmentType _equipmentType, EquipmentLevel _equipmentLevel) public {
        require(ownerOf(tokenId) == msg.sender, "NFT: not owner");
        require(nodeInfo[tokenId].equipmentLevel[_equipmentType] < _equipmentLevel, "NFT: not upgradeable");
        MachaineType _machaineType = nodeInfo[tokenId].machaineType;
        if (_machaineType == MachaineType.Regular) {
            if (_equipmentType == EquipmentType.Pipe) {
                EquipmentLevel _currentLevel = nodeInfo[tokenId].equipmentLevel[_equipmentType];
                upgradeLevel(_currentLevel, _equipmentType, _equipmentLevel, 31, 41, 50, 12, 21, 10);
            } else if (_equipmentType == EquipmentType.Gear) {
                EquipmentLevel _currentLevel = nodeInfo[tokenId].equipmentLevel[_equipmentType];
                upgradeLevel(_currentLevel, _equipmentType, _equipmentLevel, 68, 91, 110, 27, 49, 22);
            } else if (_equipmentType == EquipmentType.Grill) {
                EquipmentLevel _currentLevel = nodeInfo[tokenId].equipmentLevel[_equipmentType];
                upgradeLevel(_currentLevel, _equipmentType, _equipmentLevel, 114, 152, 183, 45, 81, 36);
            }
        } else if (_machaineType == MachaineType.Enhenced) {
            if (_equipmentType == EquipmentType.Pipe) {
                EquipmentLevel _currentLevel = nodeInfo[tokenId].equipmentLevel[_equipmentType];
                upgradeLevel(_currentLevel, _equipmentType, _equipmentLevel, 102, 136, 163, 40, 72, 32);
            } else if (_equipmentType == EquipmentType.Gear) {
                EquipmentLevel _currentLevel = nodeInfo[tokenId].equipmentLevel[_equipmentType];
                upgradeLevel(_currentLevel, _equipmentType, _equipmentLevel, 225, 300, 360, 90, 162, 72);
            } else if (_equipmentType == EquipmentType.Grill) {
                EquipmentLevel _currentLevel = nodeInfo[tokenId].equipmentLevel[_equipmentType];
                upgradeLevel(_currentLevel, _equipmentType, _equipmentLevel, 375, 500, 600, 150, 270, 120);
            }
        } else if (_machaineType == MachaineType.Finest) {
            if (_equipmentType == EquipmentType.Pipe) {
                EquipmentLevel _currentLevel = nodeInfo[tokenId].equipmentLevel[_equipmentType];
                upgradeLevel(_currentLevel, _equipmentType, _equipmentLevel, 221, 295, 354, 88, 158, 70);
            } else if (_equipmentType == EquipmentType.Gear) {
                EquipmentLevel _currentLevel = nodeInfo[tokenId].equipmentLevel[_equipmentType];
                upgradeLevel(_currentLevel, _equipmentType, _equipmentLevel, 487, 650, 780, 195, 351, 156);
            } else if (_equipmentType == EquipmentType.Grill) {
                EquipmentLevel _currentLevel = nodeInfo[tokenId].equipmentLevel[_equipmentType];
                upgradeLevel(_currentLevel, _equipmentType, _equipmentLevel, 812, 1083, 1300, 325, 585, 260);
            }
        }
        if (_equipmentType == EquipmentType.Pipe) {
            if(_equipmentLevel == EquipmentLevel.Gold) {
                nodeInfo[tokenId].unlockPeriod -= 60 days;
            } else if (_equipmentLevel == EquipmentLevel.Platinum) {
                nodeInfo[tokenId].unlockPeriod -= 90 days;
            } else if (_equipmentLevel == EquipmentLevel.Diamond) {
                nodeInfo[tokenId].unlockPeriod -= 120 days;
            }
        } else if (_equipmentType == EquipmentType.Gear) {
            if(_equipmentLevel == EquipmentLevel.Gold) {
                nodeInfo[tokenId].unlockPeriod -= 120 days;
            } else if (_equipmentLevel == EquipmentLevel.Platinum) {
                nodeInfo[tokenId].unlockPeriod -= 180 days;
            } else if (_equipmentLevel == EquipmentLevel.Diamond) {
                nodeInfo[tokenId].unlockPeriod -= 240 days;
            }
        } else if (_equipmentType == EquipmentType.Grill) {
            if(_equipmentLevel == EquipmentLevel.Gold) {
                nodeInfo[tokenId].unlockPeriod -= 180 days;
            } else if (_equipmentLevel == EquipmentLevel.Platinum) {
                nodeInfo[tokenId].unlockPeriod -= 270 days;
            } else if (_equipmentLevel == EquipmentLevel.Diamond) {
                nodeInfo[tokenId].unlockPeriod -= 360 days;
            }
        }
    }

    function upgradeLevel(
        uint256 tokenId,
        EquipmentType _equipmentType,
        EquipmentLevel _currentLevel,
        EquipmentLevel _equipmentLevel,
        uint256 _baseToGold,
        uint256 _baseToPlatinum,
        uint256 _baseToDiamond,
        uint256 _goldToPlatinum,
        uint256 _goldToDiamond,
        uint256 _platinumToDiamond
    ) internal {
        if (_currentLevel == EquipmentLevel.Base) {
            if (_equipmentLevel == EquipmentLevel.Gold) {
                USDT.transfer(receiver, _baseToGold * 10e18);
                nodeInfo[tokenId].equipmentLevel[_equipmentType] = EquipmentLevel.Gold;
            }
            if (_equipmentLevel == EquipmentLevel.Platinum) {
                USDT.transfer(receiver, _baseToPlatinum * 10e18);
                nodeInfo[tokenId].equipmentLevel[_equipmentType] = EquipmentLevel.Platinum;
            }
            if (_equipmentLevel == EquipmentLevel.Diamond) {
                USDT.transfer(receiver, _baseToDiamond * 10e18);
                nodeInfo[tokenId].equipmentLevel[_equipmentType] = EquipmentLevel.Diamond;
            }
        }
        if (_currentLevel == EquipmentLevel.Gold) {
            if (_equipmentLevel == EquipmentLevel.Platinum) {
                USDT.transfer(receiver, _goldToPlatinum * 10e18);
                nodeInfo[tokenId].equipmentLevel[_equipmentType] = EquipmentLevel.Platinum;
            }
            if (_equipmentLevel == EquipmentLevel.Diamond) {
                USDT.transfer(receiver, _goldToDiamond * 10e18);
                nodeInfo[tokenId].equipmentLevel[_equipmentType] = EquipmentLevel.Diamond;
            }
        }
        if (_currentLevel == EquipmentLevel.Platinum) {
            if (_equipmentLevel == EquipmentLevel.Diamond) {
                USDT.transfer(receiver, _platinumToDiamond * 10e18);
                nodeInfo[tokenId].equipmentLevel[_equipmentType] = EquipmentLevel.Diamond;
            }
        }
    }

    function transferFrom(address from, address to, uint256 tokenId) public override onlyTransferable {
        super.transferFrom(from, to, tokenId);
    }

    function setPromotion(bool _isPromotion) public onlyOwner {
        isPromotion = _isPromotion;
    }

    function tokenURI(uint256 tokenID) public view override returns (string memory) {}
}
