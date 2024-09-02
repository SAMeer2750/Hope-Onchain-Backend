// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Vault} from "./Vault.sol";
import {CampaignStruct} from "./library/CampaignStruct.sol";
import {FundStruct} from "./library/FundStruct.sol";
import {Events} from "./library/Events.sol";

/// @title Hope... to help KGB.
/// @author Sameer and peeps.
/// @notice Creates Campaign, Raise funds, Sends money to Vault.

contract Hope is Ownable, ReentrancyGuard {
    mapping(uint256 => CampaignStruct.Campaign) public s_campaigns;
    mapping(uint256 => bool) public s_campaignStatus;
    mapping(uint256 => uint256) public s_fundsRaised;
    mapping(uint256 => FundStruct.Fund[]) s_funds;
    uint256 private s_campaignCount;
    Vault private vault;

    constructor() Ownable(msg.sender) {
        vault = new Vault(msg.sender);
    }

    /// @notice Creates Campaign.
    /// @dev onlyOwner.
    /// @param _name Name of the campaign.
    /// @param _cId Content Identifier of the campaign details.
    /// @param _amount amount to be raised for the campaign.
    /// @param _time time to raise the amount for the campaign.
    function createCampaign(
        string memory _name,
        string memory _cId,
        uint256 _amount,
        uint256 _time
    ) external onlyOwner {
        uint256 startTime = block.timestamp;
        uint256 endTime = startTime + _time;
        s_campaignCount = s_campaignCount + 1;

        s_campaigns[s_campaignCount] = CampaignStruct.Campaign(
            s_campaignCount,
            _name,
            _cId,
            _amount,
            startTime,
            endTime
        );

        s_campaignStatus[s_campaignCount] = true;

        emit Events.CampaignCreated(
            s_campaignCount,
            _name,
            _cId,
            _amount,
            startTime,
            endTime
        );
    }

    /// @notice Raise Funds.
    /// @param _Id Campaign ID.
    function raiseFunds(uint256 _Id) external payable nonReentrant {
        require(
            s_fundsRaised[_Id] <= s_campaigns[_Id].amount,
            "Required funds already raised"
        );
        require(s_campaignStatus[_Id], "Campaign closed");

        uint256 amt = msg.value;
        //@todo check this
        if (amt > (s_campaigns[_Id].amount - s_fundsRaised[_Id])) {
            amt = (msg.value - (s_campaigns[_Id].amount - s_fundsRaised[_Id]));
            (bool success1, ) = (msg.sender).call{
                value: (s_campaigns[_Id].amount - s_fundsRaised[_Id])
            }("");
            require(success1);
        }

        s_funds[_Id].push(FundStruct.Fund(_Id, msg.sender, amt));

        s_fundsRaised[_Id] = s_fundsRaised[_Id] + amt;

        if (s_fundsRaised[_Id] == s_campaigns[_Id].amount) {
            s_campaignStatus[_Id] = true;
            emit Events.CampaignCompletelyFunded(_Id);
        }

        (bool success2, ) = (address(vault)).call{value: amt}("");
        require(success2);

        emit Events.CampaignFunded(_Id, msg.sender, amt);
    }
}
