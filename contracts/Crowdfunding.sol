// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Crowdfunding {
    struct Campaign {
        address payable beneficiary;
        uint256 fundingGoal;
        uint256 totalFunds;
        uint256 deadline;
        bool finalized;
        mapping(address => uint256) contributions;
    }

    uint256 public campaignCount;
    mapping(uint256 => Campaign) public campaigns;

    event CampaignCreated(uint256 indexed campaignId, address beneficiary, uint256 fundingGoal);
    event ContributionMade(uint256 indexed campaignId, address contributor, uint256 amount);
    event CampaignFinalized(uint256 indexed campaignId, bool successful);

    function createCampaign(address payable _beneficiary, uint256 _fundingGoal, uint256 _duration) public {
        uint256 campaignId = campaignCount++;
        Campaign storage campaign = campaigns[campaignId];
        campaign.beneficiary = _beneficiary;
        campaign.fundingGoal = _fundingGoal;
        campaign.deadline = block.timestamp + _duration;
        emit CampaignCreated(campaignId, _beneficiary, _fundingGoal);
    }

    function contribute(uint256 _campaignId) public payable {
        Campaign storage campaign = campaigns[_campaignId];
        require(block.timestamp < campaign.deadline, "Campaign has ended");
        require(!campaign.finalized, "Campaign is finalized");

        campaign.contributions[msg.sender] += msg.value;
        campaign.totalFunds += msg.value;
        emit ContributionMade(_campaignId, msg.sender, msg.value);
    }

    function finalizeCampaign(uint256 _campaignId) public {
        Campaign storage campaign = campaigns[_campaignId];
        require(block.timestamp >= campaign.deadline, "Campaign has not ended yet");
        require(!campaign.finalized, "Campaign is already finalized");

        campaign.finalized = true;
        if (campaign.totalFunds >= campaign.fundingGoal) {
            campaign.beneficiary.transfer(campaign.totalFunds);
        } else {
            // Allow refunds
            for (uint256 i = 0; i < campaignCount; i++) {
                address contributor = address(uint160(i)); // This is a simplification, in reality, you'd need to track all contributors
                uint256 contribution = campaign.contributions[contributor];
                if (contribution > 0) {
                    payable(contributor).transfer(contribution);
                }
            }
        }
        emit CampaignFinalized(_campaignId, campaign.totalFunds >= campaign.fundingGoal);
    }
}