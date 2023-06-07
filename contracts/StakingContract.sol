// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "hardhat/console.sol";

contract StakingContract is ERC20 {
    // using struct for cleaner representation as 2 mapping's
    // gas will be similar
    struct stakeStruct {
        uint256 amountStaked;
        uint256 startTime;
    }

    mapping(address => stakeStruct) public staker;
    mapping(address => uint256) public rewards;

    event staked(uint256 stakingAmount, uint256 startStakeTime);
    event Unstaked(
        uint256 stakingAmount,
        uint256 totalStakedTime,
        uint256 EndStakeTime
    );
    event claimed(address Owner, uint256 reward);

    constructor() ERC20("name", "symbol") {}

    function mint(uint256 amount) external {
        _mint(msg.sender, amount * 1e18);
    }

    function stake(uint256 _stakingAmount) external {
        require(staker[msg.sender].startTime == 0, "Already Staked");

        require(_stakingAmount <= balanceOf(msg.sender), "Balance Low");
        //using approve here to get less steps on front end we can override the function
        //else we can make function which first multiply with 1e18 and then calls the approve
        uint amount  = _stakingAmount * 1e18;
        _transfer(msg.sender, address(this), amount);
        staker[msg.sender] = stakeStruct(amount, block.timestamp);

        emit staked(_stakingAmount, staker[msg.sender].startTime);
    }

    function unStake() external {
        require(staker[msg.sender].amountStaked > 0, "Amount not staked");
        require(
            block.timestamp - staker[msg.sender].startTime > 1 minutes,
            "Cannot withdraw before minimum Staking Time"
        );
        uint256 _amount;
        uint256 endTime = block.timestamp;
        uint256 totalTime = block.timestamp - staker[msg.sender].startTime;
        _amount = staker[msg.sender].amountStaked;

        delete staker[msg.sender];

        rewardCalculate(_amount, totalTime);
        _transfer(address(this),msg.sender, _amount);
        emit Unstaked(_amount, totalTime, endTime);
    }

    function rewardCalculate(uint256 _amount, uint256 totalstakedTime) internal {
        //every 60 seconds = 1 Token (.167) it will gove 1.02  token every minute which is 60 second
        uint256 stakedTimeToken = (0.0167e18 * totalstakedTime);
        // You can get token amount reqrds if you have staked it for 3 hours
        if (totalstakedTime > 3 hours) {
            // Every 100 Token -> 1 Token
            uint256 stakedTokenReward = (_amount) / 100;
            rewards[msg.sender] = stakedTokenReward + stakedTimeToken;
        } else {
            rewards[msg.sender] = stakedTimeToken;
        }
    }

    function claim() external {
        require(rewards[msg.sender] > 0, "No rewards");
        uint256 reward = rewards[msg.sender];
        delete rewards[msg.sender];
        console.log(reward);
        _mint(msg.sender, reward);
        emit claimed(msg.sender, reward);
    }
}