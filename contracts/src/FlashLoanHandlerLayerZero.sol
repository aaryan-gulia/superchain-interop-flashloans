// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import { OAppSender } from "@layerzerolabs/oapp-evm/contracts/oapp/OAppSender.sol";
// @dev import the origin so its exposed to OApp implementers
import { OAppReceiver, Origin } from "@layerzerolabs/oapp-evm/contracts/oapp/OAppReceiver.sol";
import { OAppCore } from "@layerzerolabs/oapp-evm/contracts/oapp/OAppCore.sol";

abstract contract OApp is OAppSender, OAppReceiver {
    constructor(address _endpoint, address _owner) OAppCore(_endpoint, _owner) {}

    function oAppVersion() public pure virtual returns (uint64 senderVersion, uint64 receiverVersion) {
        senderVersion = SENDER_VERSION;
        receiverVersion = RECEIVER_VERSION;
    }
}