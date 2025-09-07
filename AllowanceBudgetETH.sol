pragma solidity ^0.8.30;

interface IERC20 {
    function transfer(address to, uint amount) external returns (bool);
    function transferFrom(address from, address to, uint amount) external returns (bool);
}

contract AllowanceBudget {

    enum AssetType { ETH, TOKEN }

    struct AllowancePlan {
        address funder;
        AssetType assetType;           
        address tokenAddress;         
        uint totalAmount;
        uint allowancePerInterval;
        uint interval;
        uint lastClaimed;
        uint remainingBalance;
    }

    mapping(address => AllowancePlan) public plans;

    event PlanCreated(
        address indexed funder,
        address indexed beneficiary,
        AssetType assetType,
        address tokenAddress,
        uint totalAmount,
        uint allowancePerInterval,
        uint interval
    );

    event AllowanceClaimed(
        address indexed beneficiary,
        uint amount,
        uint time
    );

    function createETHPlan(address beneficiary, uint allowancePerInterval, uint interval) external payable {
        require(msg.value > 0, "Must send ETH to fund plan");
        require(plans[beneficiary].funder == address(0), "Plan already exists");
        require(interval > 0, "Interval must be greater than 0");

        plans[beneficiary] = AllowancePlan({
            funder: msg.sender,
            assetType: AssetType.ETH,
            tokenAddress: address(0),
            totalAmount: msg.value,
            allowancePerInterval: allowancePerInterval,
            interval: interval,
            lastClaimed: block.timestamp,
            remainingBalance: msg.value
        });

        emit PlanCreated(msg.sender, beneficiary, AssetType.ETH, address(0), msg.value, allowancePerInterval, interval);
    }

    function createTokenPlan(address tokenAddress, address beneficiary, uint allowancePerInterval, uint interval, uint totalAmount) external {
        require(tokenAddress != address(0), "Invalid token address");
        require(plans[beneficiary].funder == address(0), "Plan already exists");
        require(interval > 0, "Interval must be greater than 0");
        require(totalAmount > 0, "Total amount must be > 0");

        IERC20 token = IERC20(tokenAddress);
        require(token.transferFrom(msg.sender, address(this), totalAmount), "Token transfer failed");

        plans[beneficiary] = AllowancePlan({
            funder: msg.sender,
            assetType: AssetType.TOKEN,
            tokenAddress: tokenAddress,
            totalAmount: totalAmount,
            allowancePerInterval: allowancePerInterval,
            interval: interval,
            lastClaimed: block.timestamp,
            remainingBalance: totalAmount
        });

        emit PlanCreated(msg.sender, beneficiary, AssetType.TOKEN, tokenAddress, totalAmount, allowancePerInterval, interval);
    }

    function claimAllowance() external {
        AllowancePlan storage plan = plans[msg.sender];
        require(plan.funder != address(0), "No plan exists");
        require(block.timestamp >= plan.lastClaimed + plan.interval, "Allowance not ready yet");
        require(plan.remainingBalance >= plan.allowancePerInterval, "Not enough balance left");

        plan.lastClaimed = block.timestamp;
        plan.remainingBalance -= plan.allowancePerInterval;

        if (plan.assetType == AssetType.ETH) {
            payable(msg.sender).transfer(plan.allowancePerInterval);
        } else {
            IERC20 token = IERC20(plan.tokenAddress);
            require(token.transfer(msg.sender, plan.allowancePerInterval), "Token transfer failed");
        }

        emit AllowanceClaimed(msg.sender, plan.allowancePerInterval, block.timestamp);
    }

    function getPlan(address beneficiary) external view returns (
        address funder,
        AssetType assetType,
        address tokenAddress,
        uint totalAmount,
        uint allowancePerInterval,
        uint interval,
        uint lastClaimed,
        uint remainingBalance
    ) {
        AllowancePlan memory plan = plans[beneficiary];
        return (
            plan.funder,
            plan.assetType,
            plan.tokenAddress,
            plan.totalAmount,
            plan.allowancePerInterval,
            plan.interval,
            plan.lastClaimed,
            plan.remainingBalance
        );
    }
}
