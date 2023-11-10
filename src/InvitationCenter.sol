// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../lib/openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract InvitationCenter is Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;

    uint256 internal constant _countOfBase58CharsOfInviterCode = 8;

    bytes32 internal constant ZERO_BYTES = hex"0000000000000000000000000000000000000000000000000000000000000000";
    //MAXS1KS7
    bytes32 internal constant _defaultInviterCode =
        hex"4D415853314B5337000000000000000000000000000000000000000000000000";

    struct Record {
        address who;
        address inviter;
        //padding with 28 zero bytes
        bytes32 invitationCode;
    }

    struct Record2 {
        uint256 index;
        address who;
        address inviter;
        //padding with 28 zero bytes
        bytes32 invitationCode;
    }

    EnumerableSet.AddressSet internal _registeredAccount;

    //who => record
    mapping(address => Record) internal _inviterRecords;

    //who => his direct invitees
    mapping(address => EnumerableSet.AddressSet) internal _inviteeRecords;

    EnumerableSet.Bytes32Set internal _registeredInvitationCode;
    mapping(bytes32 => address) internal _inviterCodeToAddress;

    constructor() Ownable(msg.sender) {}

    function registerInviterAuth(address registerApplier, bytes32 inviterCode) external {
        _registerInviter(registerApplier, inviterCode);
    }

    function _registerInviter(address registerApplier, bytes32 inviterCode) internal {
        require(!_registeredAccount.contains(registerApplier), "you have been registered");

        address inviter;

        if (inviterCode == _defaultInviterCode) {
            inviter = address(0);
        } else {
            require(_registeredInvitationCode.contains(inviterCode), "unused referral code");
            inviter = _inviterCodeToAddress[inviterCode];
        }

        _registeredAccount.add(registerApplier);
        bytes32 selfInvitationCode = _generateInvitationCode(registerApplier);
        _registeredInvitationCode.add(selfInvitationCode);
        _inviterCodeToAddress[selfInvitationCode] = registerApplier;

        Record storage registerApplierRecord = _inviterRecords[registerApplier];
        registerApplierRecord.who = registerApplier;
        registerApplierRecord.inviter = inviter;
        registerApplierRecord.invitationCode = selfInvitationCode;

        //save registerApplier to inviter's direct invitee
        //even if the inviter is address(0)
        _inviteeRecords[inviter].add(registerApplier);
    }

    function isRegistered(address who) external view returns (bool) {
        return _registeredAccount.contains(who);
    }

    function _generateInvitationCode(address requester) internal view returns (bytes32) {
        bytes32 invitationCode = _calcInvitationCode(uint256(keccak256(abi.encodePacked(requester))));

        while (_registeredInvitationCode.contains(invitationCode) || invitationCode == ZERO_BYTES) {
            invitationCode = _calcInvitationCode(uint256(keccak256(abi.encodePacked(invitationCode, requester))));
        }

        require(_validateInvitationCode(invitationCode), "_generateInvitationCode error");

        return invitationCode;
    }

    //a !!!MODIFIED!!! base32 , 2^5
    function _calcInvitationCode(uint256 random) internal pure returns (bytes32) {
        bytes memory res = "";
        for (uint256 i = 0; i < _countOfBase58CharsOfInviterCode; i++) {
            //get endian 5 bytes
            uint256 endian = random % (2 ** 5);
            random = random / (2 ** 5);

            if (endian == 0) {
                res = abi.encodePacked(res, "A");
            } else if (endian == 1) {
                res = abi.encodePacked(res, "B");
            } else if (endian == 2) {
                res = abi.encodePacked(res, "C");
            } else if (endian == 3) {
                res = abi.encodePacked(res, "D");
            } else if (endian == 4) {
                res = abi.encodePacked(res, "E");
            } else if (endian == 5) {
                res = abi.encodePacked(res, "F");
            } else if (endian == 6) {
                res = abi.encodePacked(res, "G");
            } else if (endian == 7) {
                res = abi.encodePacked(res, "H");
            } else if (endian == 8) {
                res = abi.encodePacked(res, "J");
            } else if (endian == 9) {
                res = abi.encodePacked(res, "K");
            } else if (endian == 10) {
                res = abi.encodePacked(res, "L");
            } else if (endian == 11) {
                res = abi.encodePacked(res, "M");
            } else if (endian == 12) {
                res = abi.encodePacked(res, "N");
            } else if (endian == 13) {
                res = abi.encodePacked(res, "P");
            } else if (endian == 14) {
                res = abi.encodePacked(res, "Q");
            } else if (endian == 15) {
                res = abi.encodePacked(res, "R");
            } else if (endian == 16) {
                res = abi.encodePacked(res, "S");
            } else if (endian == 17) {
                res = abi.encodePacked(res, "T");
            } else if (endian == 18) {
                res = abi.encodePacked(res, "U");
            } else if (endian == 19) {
                res = abi.encodePacked(res, "V");
            } else if (endian == 20) {
                res = abi.encodePacked(res, "W");
            } else if (endian == 21) {
                res = abi.encodePacked(res, "X");
            } else if (endian == 22) {
                res = abi.encodePacked(res, "Y");
            } else if (endian == 23) {
                res = abi.encodePacked(res, "Z");
            } else if (endian == 24) {
                res = abi.encodePacked(res, "2");
            } else if (endian == 25) {
                res = abi.encodePacked(res, "3");
            } else if (endian == 26) {
                res = abi.encodePacked(res, "4");
            } else if (endian == 27) {
                res = abi.encodePacked(res, "5");
            } else if (endian == 28) {
                res = abi.encodePacked(res, "6");
            } else if (endian == 29) {
                res = abi.encodePacked(res, "7");
            } else if (endian == 30) {
                res = abi.encodePacked(res, "8");
            } else if (endian == 31) {
                res = abi.encodePacked(res, "9");
            } else {
                revert("_calcInvitationCode, _calcInvitationCode error");
            }
        }

        bytes32 ret;
        assembly {
            ret := mload(add(res, 32))
        }

        require(_validateInvitationCode(ret), "_calcInvitationCode, _calcInvitationCode then check failed");

        return ret;
    }

    //only validate generator rule
    function _validateInvitationCode(bytes32 input) internal pure returns (bool) {
        uint256 remainder = uint256(input) % ((2 ** 8) ** (uint256(32) - _countOfBase58CharsOfInviterCode));
        return remainder == uint256(0);
    }

    function inviterRecords(address who) external view returns (Record memory) {
        return _inviterRecords[who];
    }

    function registeredAccountLength() external view returns (uint256) {
        return _registeredAccount.length();
    }

    function registeredAccountAt(uint256 index) external view returns (address) {
        return _registeredAccount.at(index);
    }

    function registeredAccountContains(address who) external view returns (bool) {
        return _registeredAccount.contains(who);
    }

    function inviteeRecordsLength(address who) external view returns (uint256) {
        return _inviteeRecords[who].length();
    }

    function inviteeRecordsAt(address who, uint256 index) external view returns (address) {
        return _inviteeRecords[who].at(index);
    }

    function inviteeRecordsContains(address who, address invitee) external view returns (bool) {
        return _inviteeRecords[who].contains(invitee);
    }

    function registeredInvitationCodeLength() external view returns (uint256) {
        return _registeredInvitationCode.length();
    }

    function registeredInvitationCodeAt(uint256 index) external view returns (bytes32) {
        return _registeredInvitationCode.at(index);
    }

    function registeredInvitationCodeContains(bytes32 input) external view returns (bool) {
        return _registeredInvitationCode.contains(input);
    }

    function inviterCodeToAddress(bytes32 input) external view returns (address) {
        return _inviterCodeToAddress[input];
    }

    function getRegisterDetail(uint256 start, uint256 length) external view returns (Record2[] memory) {
        uint256 totalLength = _registeredAccount.length();

        if (totalLength <= start) {
            return new Record2[](0);
        } else {
            //start < totalLength
            uint256 remaining = totalLength - start;
            if (remaining < length) {
                length = remaining;
            }

            Record2[] memory ret = new Record2[](length);
            for (uint256 i = 0; i < length; i++) {
                address who = _registeredAccount.at(start + i);
                Record storage s = _inviterRecords[who];
                ret[i].index = start + i;
                ret[i].who = s.who;
                ret[i].inviter = s.inviter;
                ret[i].invitationCode = s.invitationCode;
            }
            return ret;
        }
    }

    function getRegister(uint256[] calldata offsets) external view returns (Record[] memory) {
        Record[] memory ret = new Record[](offsets.length);

        for (uint256 i = 0; i < offsets.length; i++) {
            address who = _registeredAccount.at(offsets[i]);
            ret[i] = _inviterRecords[who];
        }

        return ret;
    }

    function manualRegister(Record[] calldata params) external onlyOwner {
        for (uint256 i = 0; i < params.length; i++) {
            Record calldata param = params[i];

            /*if(_registeredAccount.contains(param.who)){
                continue;
            }*/

            _registeredAccount.add(param.who);
            _registeredInvitationCode.add(param.invitationCode);
            _inviterCodeToAddress[param.invitationCode] = param.who;

            Record storage record = _inviterRecords[param.who];
            record.who = param.who;
            record.inviter = param.inviter;
            record.invitationCode = param.invitationCode;

            _inviteeRecords[param.inviter].add(param.who);
        }
    }
}
