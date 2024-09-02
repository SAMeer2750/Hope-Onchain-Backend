// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

library CampaignStruct {
    struct Campaign {
        uint256 Id;
        string name;
        string cId;
        uint256 amount;
        uint256 startTime;
        uint256 endTime;
    }
}