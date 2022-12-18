// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.9.0;

contract ext {
    constructor() {}

    enum Stage {
        Registration,
        Commit,
        Reveal
    }

    Stage private ans;
    bytes private res;
    bool private isGood;

    function eGetStage(address rps) external {
        (isGood, res) = rps.call(
            abi.encodeWithSignature("getStatus()")
        );
        ans = abi.decode(res, (Stage));
    }
}
