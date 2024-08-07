// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./IERC20.sol";
import "./ReentrancyGuard.sol";
import "./Initializable.sol";
import "./Ownable.sol";

contract StakingToken is ReentrancyGuard, Ownable, Initializable {
    struct User {
        uint256 stakeAmount;
        uint256 rewardAmount;
        uint256 lastStakeTime;
        uint256 lastCalculatedRewardTime;
        uint256 rewardClaimedSoFar;
    }

    uint256 public minimumStakeAmount;
    uint256 public maximumStakeAmount;
    uint256 public stakeStartDate;
    uint256 public stakeEndDate;
    uint256 public stakeDays;
    uint256 public totalUsers;
    uint256 public totalStakeTokens;
    uint256 public earlyUnstakeFeePercentage;
    bool public isPaused;

    address private tokenAddress;

    uint256 public apyRate;

    uint256 public constant PERCENTAGE_DENOMINATOR = 1000;
    uint256 public constant APY_RATE_THRESHOLD = 10;

    mapping(address => User) private user;

    event Stake(address indexed user, uint256 amount);
    event Unstake(address indexed user, uint256 amount);
    event EarlyUnstakeFee(address indexed user, uint256 fee);
    event ClaimedReward(address indexed user, uint256 amount);

    modifier whenTresuryHasBalance(uint256 amount) {
        require(
            IERC20(tokenAddress).balanceof(address(this)) >= amount,
            "Insufficient Funds in the treasury"
        );
        _;
    }

    function initialize(
        address _owner,
        address _tokenAddress,
        uint256 _minStakeAmount,
        uint256 _maxStakeAmount,
        uint256 _apyRate,
        uint256 _earlyUnstakeFeePercentage,
        uint256 _stakeStartDays,
        uint256 _stakeEndDate,
        uint256 _stakeDays
    ) public virtual initializer {
        __TokenStaking_init_unchained(
            _owner,
            _tokenAddress,
            _minStakeAmount,
            _maxStakeAmount,
            _apyRate,
            _earlyUnstakeFeePercentage,
            _stakeStartDays,
            _stakeEndDate,
            _stakeDays
        );
    }

    function __TokenStaking_init_unchained(
        address _owner,
        address _tokenAddress,
        uint256 _minStakeAmount,
        uint256 _maxStakeAmount,
        uint256 _apyRate,
        uint256 _earlyUnstakeFeePercentage,
        uint256 _stakeStartDays,
        uint256 _stakeEndDate,
        uint256 _stakeDays
    ) internal onlyInitializer {
        require(_apyRate <= 1000, "apy rate must be less than 1000");
        require(
            _tokenAddress != address(0),
            "Token address must not be a zero address"
        );
        require(_stakeDays > 0, "Stake Days must be greater than 0");
        require(
            _stakeStartDays < _stakeEndDate,
            "Stake start date must be less than the end date"
        );

        _transferOwnership(_owner);
        tokenAddress = _tokenAddress;
        apyRate = _apyRate;
        earlyUnstakeFeePercentage = _earlyUnstakeFeePercentage;
        stakeDays = _stakeDays * 1 days;
        stakeStartDate = _stakeStartDays;
        stakeEndDate = _stakeEndDate;
        minimumStakeAmount = _minStakeAmount;
        maximumStakeAmount = _maxStakeAmount;
    }

    // -<----- View method start ------->

    /**
     * @notice This function get the token start date
     */
    function getStartDate() external view returns (uint256) {
        return stakeStartDate;
    }

    /**
     * @notice This function get the token end date
     */
    function getEndDate() external view returns (uint256) {
        return stakeEndDate;
    }

    /**
     * @notice This function get the minimum stake amount
     */
    function getMinimumStakeAmount() external view returns (uint256) {
        return minimumStakeAmount;
    }

    /**
     * @notice This function get the maximum stake amount
     */
    function getMaximumStakeAmount() external view returns (uint256) {
        return maximumStakeAmount;
    }

    /**
     * @notice This function get the stake days
     */
    function getStakeDays() external view returns (uint256) {
        return stakeDays;
    }

    /**
     * @notice This function get the total users
     */
    function getTotalUsers() external view returns (uint256) {
        return totalUsers;
    }

    /**
     * @notice This function get the total staked tokens
     */
    function getTotalStakeTokens() external view returns (uint256) {
        return totalStakeTokens;
    }

    /**
     * @notice This function get the early unstake fee percentage
     */
    function getEarlyUnstakeFeePercentage() external view returns (uint256) {
        return earlyUnstakeFeePercentage;
    }

    /**
     * @notice This function get if contract is paused
     */
    function getIsPaused() external view returns (bool) {
        return isPaused;
    }

    /**
     * @notice This function get the apy rate
     */
    function getApyRate() external view returns (uint256) {
        return apyRate;
    }

    /**
     * @notice This function get the estimated rewards
     */
    function getUserEstimatedRewards() external view returns (uint256) {
        (uint256 amount, ) = _getUserEstimatedRewards(msg.sender);
        return user[msg.sender].rewardAmount + amount;
    }

    /**
     * @notice This function get the withdrawable amount
     */
    function getWithdrawableAmount() external view returns (uint256) {
        return (IERC20(tokenAddress).balanceof(address(this)) -
            totalStakeTokens);
    }

    /**
     * @notice This function get the user details
     * @param user_address is the address of a user
     * @return returns user details.
     */
    function getUserDetails(address _user) external view returns (User memory) {
        return user[_user];
    }

    /**
     * @notice This function get if user is a stake holder
     * @param user_address is the address of a user
     */
    function isStakeHolder(address _user) external view returns (bool) {
        return (user[_user].stakeAmount > 0);
    }

    // <--------- View End ---------->

    // <--------- Only Owner --------->

    /**
     * @notice this function updates the stake minimum stake amount
     */
    function updateMinimumStakeAmount(uint256 newAmount) external OnlyOwner {
        minimumStakeAmount = newAmount;
    }

    /**
     * @notice this function updates the stake maximum stake amount
     */
    function updateMaximumStakeAmount(uint256 newAmount) external OnlyOwner {
        maximumStakeAmount = newAmount;
    }

    /**
     * @notice this function updates the early unstake fee percentage
     */
    function updateEarlyUnstakeFeePercentage(
        uint256 newAmount
    ) external OnlyOwner {
        earlyUnstakeFeePercentage = newAmount;
    }

    /**
     * @notice this function updates the stake end date
     */
    function updateStakeEndDate(uint256 newDate) external OnlyOwner {
        stakeEndDate = newDate;
    }

    /**
     * @notice stakes for users
     * @dev this function allows owner stake for user
     * @param user users address
     * @param amount amount to stake
     */
    function stakeForUser(
        uint256 amount,
        address _user
    ) external OnlyOwner nonReentrant {
        _stakeForUser(amount, _user);
    }

    /**
     * @notice enable/disable staking status
     * @dev this function toggles staking status
     */
    function toggingStaking() external OnlyOwner {
        isPaused = !isPaused;
    }

    /**
     * @notice withdraws token
     * @param amount
     */
    function withdraw(uint256 amount) external OnlyOwner nonReentrant {
        require(
            this.getWithdrawableAmount() >= amount,
            "amount must not be greate than the available amount"
        );
        IERC20(tokenAddress).transfer(msg.sender, amount);
    }

    // <-------Only Owners methods ------->

    // <-------- User methods ----------->

    /**
     * @notice users can stake tokens
     * @param amount amount to be staked
     */
    function stake(uint256 amount) external nonReentrant {
        _stakeForUser(amount, msg.sender);
    }

    function _stakeForUser(uint256 amount, address _user) private {
        require(!isPaused, "staking is paused");

        uint256 currentTime = getCurrentTime();
        require(currentTime > stakeStartDate, "stake time has not begin");
        require(currentTime < stakeEndDate, "stake time has ended");
        require(amount > 0, "amount must be greater than 0");
        require(
            amout + totalStakeTokens <= maximumStakeAmount,
            "maximim stake limit exceeded"
        );
        require(
            amount > minimumStakeAmount,
            "amount must be greater than the minimum stake amount"
        );

        if (user[_user].stakeAmount != 0) {
            _calculateReward(_user);
        } else {
            totalUsers += 1;
            user[_user].lastCalculatedRewardTime = currentTime;
        }
        totalStakeTokens += amount;
        user[_user].stakeAmount += amount;
        user[_user].lastStakeTime += currentTime;

        require(
            IERC20(tokenAddress).transferFrom(
                msg.sender,
                address(this),
                amount
            ),
            "Transfer not successful"
        );
        emit Stake(_user, amount);
    }

    function unstake(
        uint256 _amount
    ) external nonReentrant whenTresuryHasBalance(_amount) {
        address _user = msg.sender;

        require(amount > 0, "Amount must be graeter than 0");
        require(this.isStakeHolder(_user), "User must be a stake holder");
        require(
            user[_user].stakeAmount >= _amount,
            "amount to unstake is greater than what you staked initialy"
        );

        _calculateReward(_user);
        uint256 earlyFeeUnstake;

        if (getCurrentTime() <= user[_user].lastStakeTime + stakeDays) {
            earlyFeeUnstake = ((_amount * earlyUnstakeFeePercentage) /
                PERCENTAGE_DENOMINATOR);
            emit EarlyUnstakeFee(user, earlyFeeUnstake);
        }

        uint256 amountToUnstake = _amount - earlyFeeUnstake;
        user[_user].stakeAmount -= _amount;
        totalStakeTokens -= _amount;

        if (user[_user].stakeAmount == 0) {
            // delete user
            totalUsers -= 1;
        }
        require(
            IERC20(tokenAddress).transfer(_user, amountToUnstake),
            "Transfer was unsuccessful"
        );
        emit Unstake(user, _amount);
    }

    function claimReward()
        external
        nonReentrant
        whenTresuryHasBalance(user[_user].rewardAmount)
    {
        _calculateReward(msg.sender);
        uint256 rewardAmount = user[msg.sender].rewardAmount;

        require(rewardAmount > 0, "reward amount must be greater than zero");
        require(
            IERC20(tokenAddress).transfer(msg.sender, rewardAmount),
            "Transfer reward was unsuccessful"
        );

        user[msg.sender].rewardAmount -= rewardAmount;
        user[msg.sender].rewardClaimedSoFar += rewardAmount;

        emit ClaimedReward(msg.sender, rewardAmount);
    }

    // <------ End User Method ------->

    // <------- Private Functions -------->

    function _calculateReward(address _user) private {
        (uint256 rewardAmount, uint256 currentTime) = _getUserEstimatedRewards(
            _user
        );
        user[_user].rewardAmount += rewardAmount;
        user[_user].lastCalculatedRewardTime += currentTime;
    }

    function _getUserEstimatedRewards(
        address _user
    ) private view returns (uint256, uint256) {
        uint256 userReward;
        uint256 userTimeStamp = user[_user].lastCalculatedRewardTime;
        uint256 currentTime = getCurrentTime();

        if (currentTime > user[_user].lastStakeTime + stakeDays) {
            currentTime = user[_user].lastStakeTime + stakeDays;
        }
        uint256 totalStakedTime = currentTime - userTimeStamp;
        userReward +=
            ((totalStakedTime * user[_user].stakeAmount * apyRate) / 365 days) /
            PERCENTAGE_DENOMINATOR;
        return (userReward, currentTime);
    }

    function getCurrentTime() internal view virtual returns (uint256) {
        return block.timestamp;
    }
}
