// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract Node is ERC721Enumerable, Ownable {
    using SafeERC20 for IERC20;

    enum MachineType {
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

    event upgradeEvent(
        uint256 indexed tokenId,
        address inviter,
        EquipmentType equipmentType,
        EquipmentLevel equipmentLevel,
        uint256 time
    );

    event mintEvent(uint256 indexed tokenId, address user, uint256 amount, address inviter, MachineType _MachineType);

    struct NodeInfo {
        MachineType MachineType;
        EquipmentType[] equipmentType;
        mapping(EquipmentType => EquipmentLevel) equipmentLevel;
        uint256 mintTime;
        uint256 unlockPeriod;
        uint256 totalToken;
    }

    bool public transferable;
    uint256 public nextTokenID;
    mapping(uint256 => NodeInfo) public nodeInfo;
    IERC20 public USDT;
    IERC20 public Zeb;
    address public fund;
    address public signer;

    modifier onlyTransferable() {
        require(transferable, "NFT: not transferable");
        _;
    }

    constructor(string memory name, string memory symbol, address _usdt, address _zeb, address _fund, address _signer)
        ERC721(name, symbol)
        Ownable(msg.sender)
    {
        USDT = IERC20(_usdt);
        Zeb = IERC20(_zeb);
        fund = _fund;
        signer = _signer;
    }

    function getEquipmentLevel(uint256 tokenId) public view returns(EquipmentLevel[] memory) {
        EquipmentLevel[] memory _equipmentLevel = new EquipmentLevel[](3);
        _equipmentLevel[0] = nodeInfo[tokenId].equipmentLevel[EquipmentType.Pipe];
        _equipmentLevel[1] = nodeInfo[tokenId].equipmentLevel[EquipmentType.Gear];
        _equipmentLevel[2] = nodeInfo[tokenId].equipmentLevel[EquipmentType.Grill];
        return _equipmentLevel;
    }

    function publicMint(
        MachineType[] memory _machineType,
        uint256[] memory amount,
        address inviter,
        uint256 discount,
        uint256 time,
        address user,
        bytes memory evidence
    ) public {
        for (uint256 i = 0; i < _machineType.length; i++) {
            mint(_machineType[i], amount[i], inviter, discount, time, user, evidence);
        }
    }

    function mint(MachineType _MachineType, uint256 amount, address inviter, uint256 discount, uint256 time, address user, bytes memory evidence)
        internal
    {   
        require(time + 5 minutes > block.timestamp, "evidence expired");
        require(user == msg.sender, "invalid user");
        uint256 totalToken;
        require(_validate(keccak256(abi.encode(inviter, discount, time, user)), evidence, signer), "invalid evidence");
        if (_MachineType == MachineType.Regular) {
            USDT.transferFrom(msg.sender, fund, 500 * 10e18 * amount * 95 * discount / 1e4);
            USDT.transferFrom(msg.sender, inviter, 500 * 10e18 * amount * 5 * discount / 1e4);
            totalToken = 1200;
        }
        if (_MachineType == MachineType.Enhenced) {
            USDT.transferFrom(msg.sender, fund, 800 * 10e18 * amount * 95 * discount / 1e4);
            USDT.transferFrom(msg.sender, inviter, 800 * 10e18 * amount * 5 * discount / 1e4);
            totalToken = 2000;
        }
        if (_MachineType == MachineType.Finest) {
            USDT.transferFrom(msg.sender, fund, 1200 * 10e18 * amount * 95 * discount / 1e4);
            USDT.transferFrom(msg.sender, inviter, 1200 * 10e18 * amount * 5 * discount / 1e4);
            totalToken = 3200;
        }
        for (uint256 i = 0; i < amount; i++) {
            uint256 tokenId = nextTokenID;
            nextTokenID++;
            _mint(msg.sender, tokenId);
            nodeInfo[tokenId].MachineType = _MachineType;
            nodeInfo[tokenId].mintTime = block.timestamp;
            nodeInfo[tokenId].unlockPeriod = 1440 days;
            nodeInfo[tokenId].totalToken = totalToken;
            emit mintEvent(tokenId, msg.sender, amount, inviter, _MachineType);
        }
    }

    function multipleUpgrade(
        bool isUSDT,
        uint256 tokenId,
        EquipmentType[] memory _equipmentType,
        EquipmentLevel[] memory _equipmentLevel,
        address inviter,
        uint256 zebPrice,
        uint256 time,
        address user,
        bytes memory evidence
    ) public {
        for (uint256 i = 0; i < _equipmentType.length; i++) {
            upgrade(isUSDT, tokenId, _equipmentType[i], _equipmentLevel[i], inviter, zebPrice, time, user, evidence);
        }
    }

    function upgrade(
        bool isUSDT,
        uint256 tokenId,
        EquipmentType _equipmentType,
        EquipmentLevel _equipmentLevel,
        address inviter,
        uint256 zebPrice,
        uint256 time,
        address user,
        bytes memory evidence
    ) public {
        require(time + 5 minutes > block.timestamp, "evidence expired");
        require(user == msg.sender, "invalid user");
        require(_validate(keccak256(abi.encode(zebPrice, inviter, time, user)), evidence, signer), "invalid evidence");
        require(ownerOf(tokenId) == msg.sender, "NFT: not owner");
        require(nodeInfo[tokenId].equipmentLevel[_equipmentType] < _equipmentLevel, "NFT: not upgradeable");
        MachineType _MachineType = nodeInfo[tokenId].MachineType;
        if (_MachineType == MachineType.Regular) {
            if (_equipmentType == EquipmentType.Pipe) {
                EquipmentLevel _currentLevel = nodeInfo[tokenId].equipmentLevel[_equipmentType];
                upgradeLevel(
                    inviter,
                    zebPrice,
                    isUSDT,
                    tokenId,
                    _currentLevel,
                    _equipmentType,
                    _equipmentLevel,
                    31,
                    41,
                    50,
                    12,
                    21,
                    10
                );
            } else if (_equipmentType == EquipmentType.Gear) {
                EquipmentLevel _currentLevel = nodeInfo[tokenId].equipmentLevel[_equipmentType];
                upgradeLevel(
                    inviter,
                    zebPrice,
                    isUSDT,
                    tokenId,
                    _currentLevel,
                    _equipmentType,
                    _equipmentLevel,
                    68,
                    91,
                    110,
                    27,
                    49,
                    22
                );
            } else if (_equipmentType == EquipmentType.Grill) {
                EquipmentLevel _currentLevel = nodeInfo[tokenId].equipmentLevel[_equipmentType];
                upgradeLevel(
                    inviter,
                    zebPrice,
                    isUSDT,
                    tokenId,
                    _currentLevel,
                    _equipmentType,
                    _equipmentLevel,
                    114,
                    152,
                    183,
                    45,
                    81,
                    36
                );
            }
        } else if (_MachineType == MachineType.Enhenced) {
            if (_equipmentType == EquipmentType.Pipe) {
                EquipmentLevel _currentLevel = nodeInfo[tokenId].equipmentLevel[_equipmentType];
                upgradeLevel(
                    inviter,
                    zebPrice,
                    isUSDT,
                    tokenId,
                    _currentLevel,
                    _equipmentType,
                    _equipmentLevel,
                    102,
                    136,
                    163,
                    40,
                    72,
                    32
                );
            } else if (_equipmentType == EquipmentType.Gear) {
                EquipmentLevel _currentLevel = nodeInfo[tokenId].equipmentLevel[_equipmentType];
                upgradeLevel(
                    inviter,
                    zebPrice,
                    isUSDT,
                    tokenId,
                    _currentLevel,
                    _equipmentType,
                    _equipmentLevel,
                    225,
                    300,
                    360,
                    90,
                    162,
                    72
                );
            } else if (_equipmentType == EquipmentType.Grill) {
                EquipmentLevel _currentLevel = nodeInfo[tokenId].equipmentLevel[_equipmentType];
                upgradeLevel(
                    inviter,
                    zebPrice,
                    isUSDT,
                    tokenId,
                    _currentLevel,
                    _equipmentType,
                    _equipmentLevel,
                    375,
                    500,
                    600,
                    150,
                    270,
                    120
                );
            }
        } else if (_MachineType == MachineType.Finest) {
            if (_equipmentType == EquipmentType.Pipe) {
                EquipmentLevel _currentLevel = nodeInfo[tokenId].equipmentLevel[_equipmentType];
                upgradeLevel(
                    inviter,
                    zebPrice,
                    isUSDT,
                    tokenId,
                    _currentLevel,
                    _equipmentType,
                    _equipmentLevel,
                    221,
                    295,
                    354,
                    88,
                    158,
                    70
                );
            } else if (_equipmentType == EquipmentType.Gear) {
                EquipmentLevel _currentLevel = nodeInfo[tokenId].equipmentLevel[_equipmentType];
                upgradeLevel(
                    inviter,
                    zebPrice,
                    isUSDT,
                    tokenId,
                    _currentLevel,
                    _equipmentType,
                    _equipmentLevel,
                    487,
                    650,
                    780,
                    195,
                    351,
                    156
                );
            } else if (_equipmentType == EquipmentType.Grill) {
                EquipmentLevel _currentLevel = nodeInfo[tokenId].equipmentLevel[_equipmentType];
                upgradeLevel(
                    inviter,
                    zebPrice,
                    isUSDT,
                    tokenId,
                    _currentLevel,
                    _equipmentType,
                    _equipmentLevel,
                    812,
                    1083,
                    1300,
                    325,
                    585,
                    260
                );
            }
        }
        if (_equipmentType == EquipmentType.Pipe) {
            if (_equipmentLevel == EquipmentLevel.Gold) {
                nodeInfo[tokenId].unlockPeriod -= 60 days;
            } else if (_equipmentLevel == EquipmentLevel.Platinum) {
                nodeInfo[tokenId].unlockPeriod -= 90 days;
            } else if (_equipmentLevel == EquipmentLevel.Diamond) {
                nodeInfo[tokenId].unlockPeriod -= 120 days;
            }
        } else if (_equipmentType == EquipmentType.Gear) {
            if (_equipmentLevel == EquipmentLevel.Gold) {
                nodeInfo[tokenId].unlockPeriod -= 120 days;
            } else if (_equipmentLevel == EquipmentLevel.Platinum) {
                nodeInfo[tokenId].unlockPeriod -= 180 days;
            } else if (_equipmentLevel == EquipmentLevel.Diamond) {
                nodeInfo[tokenId].unlockPeriod -= 240 days;
            }
        } else if (_equipmentType == EquipmentType.Grill) {
            if (_equipmentLevel == EquipmentLevel.Gold) {
                nodeInfo[tokenId].unlockPeriod -= 180 days;
            } else if (_equipmentLevel == EquipmentLevel.Platinum) {
                nodeInfo[tokenId].unlockPeriod -= 270 days;
            } else if (_equipmentLevel == EquipmentLevel.Diamond) {
                nodeInfo[tokenId].unlockPeriod -= 360 days;
            }
        }
        emit upgradeEvent(tokenId, inviter, _equipmentType, _equipmentLevel, block.timestamp);
    }

    function upgradeLevel(
        address inviter,
        uint256 ZebPrice,
        bool isUSDT,
        uint256 tokenId,
        EquipmentLevel _currentLevel,
        EquipmentType _equipmentType,
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
                if (isUSDT) {
                    USDT.transferFrom(msg.sender, fund, _baseToGold * 95 * 10e16);
                    USDT.transferFrom(msg.sender, inviter, _baseToGold * 5 * 10e16);
                } else {
                    Zeb.transferFrom(msg.sender, fund, _baseToGold * 95 * 10e7 / ZebPrice);
                    Zeb.transferFrom(msg.sender, inviter, _baseToGold * 5 * 10e7 / ZebPrice);
                }
                nodeInfo[tokenId].equipmentLevel[_equipmentType] = EquipmentLevel.Gold;
            }
            if (_equipmentLevel == EquipmentLevel.Platinum) {
                if (isUSDT) {
                    USDT.transferFrom(msg.sender, fund, _baseToPlatinum * 95 * 10e16);
                    USDT.transferFrom(msg.sender, inviter, _baseToPlatinum * 5 * 10e16);
                } else {
                    Zeb.transferFrom(msg.sender, fund, _baseToPlatinum * 95 * 10e7 / ZebPrice);
                    Zeb.transferFrom(msg.sender, inviter, _baseToPlatinum * 5 * 10e7 / ZebPrice);
                }
                nodeInfo[tokenId].equipmentLevel[_equipmentType] = EquipmentLevel.Platinum;
            }
            if (_equipmentLevel == EquipmentLevel.Diamond) {
                if (isUSDT) {
                    USDT.transferFrom(msg.sender, fund, _baseToDiamond * 95 * 10e16);
                    USDT.transferFrom(msg.sender, inviter, _baseToDiamond * 5 * 10e16);
                } else {
                    Zeb.transferFrom(msg.sender, fund, _baseToDiamond * 95 * 10e7 / ZebPrice);
                    Zeb.transferFrom(msg.sender, inviter, _baseToDiamond * 5 * 10e7 / ZebPrice);
                }
                nodeInfo[tokenId].equipmentLevel[_equipmentType] = EquipmentLevel.Diamond;
            }
        }
        if (_currentLevel == EquipmentLevel.Gold) {
            if (_equipmentLevel == EquipmentLevel.Platinum) {
                if (isUSDT) {
                    USDT.transferFrom(msg.sender, fund, _goldToPlatinum * 95 * 10e16);
                    USDT.transferFrom(msg.sender, inviter, _goldToPlatinum * 5 * 10e16);
                } else {
                    Zeb.transferFrom(msg.sender, fund, _goldToPlatinum * 95 * 10e7 / ZebPrice);
                    Zeb.transferFrom(msg.sender, inviter, _goldToPlatinum * 5 * 10e7 / ZebPrice);
                }
                nodeInfo[tokenId].equipmentLevel[_equipmentType] = EquipmentLevel.Platinum;
            }
            if (_equipmentLevel == EquipmentLevel.Diamond) {
                if (isUSDT) {
                    USDT.transferFrom(msg.sender, fund, _goldToDiamond * 95 * 10e16);
                    USDT.transferFrom(msg.sender, inviter, _goldToDiamond * 5 * 10e16);
                } else {
                    Zeb.transferFrom(msg.sender, fund, _goldToDiamond * 95 * 10e7 / ZebPrice);
                    Zeb.transferFrom(msg.sender, inviter, _goldToDiamond * 5 * 10e7 / ZebPrice);
                }
                nodeInfo[tokenId].equipmentLevel[_equipmentType] = EquipmentLevel.Diamond;
            }
        }
        if (_currentLevel == EquipmentLevel.Platinum) {
            if (_equipmentLevel == EquipmentLevel.Diamond) {
                if (isUSDT) {
                    USDT.transferFrom(msg.sender, fund, _platinumToDiamond * 95 * 10e16);
                    USDT.transferFrom(msg.sender, inviter, _platinumToDiamond * 5 * 10e16);
                } else {
                    Zeb.transferFrom(msg.sender, fund, _platinumToDiamond * 95 * 10e7 / ZebPrice);
                    Zeb.transferFrom(msg.sender, inviter, _platinumToDiamond * 5 * 10e7 / ZebPrice);
                }
                nodeInfo[tokenId].equipmentLevel[_equipmentType] = EquipmentLevel.Diamond;
            }
        }
    }

    // function transferFrom(address from, address to, uint256 tokenId) public override onlyTransferable {
    //     super.transferFrom(from, to, tokenId);
    // }

    function tokenURI(uint256 tokenID) public view override returns (string memory) {}

    /// @dev validate signature msg
    function _validate(bytes32 message, bytes memory signature, address _signer) internal pure returns (bool) {
        require(_signer != address(0) && signature.length == 65);

        bytes32 r;
        bytes32 s;
        uint8 v = uint8(signature[64]) + 27;
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
        }
        return ecrecover(message, v, r, s) == _signer;
    }
}
