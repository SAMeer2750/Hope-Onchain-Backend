// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

library Events {
    event CampaignCreated(
        uint256 Id,
        string name,
        string cId,
        uint256 amount,
        uint256 startTime,
        uint256 endTime
    );

    event CampaignFunded(
        uint256 campaignId,
        address add,
        uint256 amount
    );

    event CampaignCompletelyFunded(
        uint256 campaignId
    );
}