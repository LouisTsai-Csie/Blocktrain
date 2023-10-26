// SPDX-License-Identifier: MIT
pragma solidity =0.8.20;

// import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/v0.8/dev/VRFConsumerBase.sol";

contract RandomNumber is VRFConsumerBase {
    event RequestFulfilled(bytes32 requestId, uint256 randomness);
    
    bytes32 internal keyHash; // VRF唯一标识符
    uint256 internal fee; // VRF使用手续费
    
    uint256 public randomResult; // 存储随机数

    constructor() 
        VRFConsumerBase(
            0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625, 
            0x779877A7B0D9E8603169DdbD7836e478b4624789
        )
    {
        keyHash = 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311;
        fee = 0.25 * 10 ** 18;
    }

    function getRandomNumber() public returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");

        return requestRandomness(keyHash, fee);
    }

    function fulfillRandomness(
        bytes32 requestId,
        uint256 randomness
    ) internal override {
        randomResult = randomness;
        emit RequestFulfilled(requestId, randomness);
    }

}