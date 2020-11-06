pragma solidity >=0.4.22 <0.7.0;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";

contract Investments {
    
     using SafeMath for uint;
    
    address public CEO;
    address internal implementation;
    uint rewardTime = 1 days;
    
    mapping(address => uint) private balances;
    mapping(address => uint) public lockTime;
    
    event ValueReceived(address user, uint amount);

     constructor() public {
        CEO = msg.sender;
     }
    
      /**
     * @dev Confirms if person calling the function is the creator of the contract
     *
     */
    modifier isOwner() {
        require(msg.sender == CEO, "You are not my supervisor");
        _;
    }
    
       /**
     * @dev Confirms if amount to be withdrawn is not more than user's balance
     *
     */
    modifier canWithdraw(address _userAddr) {
        require(now >= lockTime[_userAddr], "You have to wait 24 hours to withdraw your funds plus interest");
        _;
    }
    
    function _lockTime(address _userAddr, uint _time) public {
      lockTime[_userAddr] += _time;
    }
    
   
    function invest() payable public returns (uint) {
        address payable user = msg.sender;
        uint accumulated = (msg.value * 20 / 100) + msg.value;
        balances[user] = balances[user].add(accumulated);
        _lockTime(user, now + rewardTime);
        return balances[user];
    }
    
    function withdraw() public canWithdraw(msg.sender) returns(uint balance) {
        address payable user = msg.sender;
        uint amount = balances[user];
        (bool success, ) = msg.sender.call.value(amount)("");
        require(success, "Withdrawal failed.");
        amount = 0;
        return amount;
    }
    
    function checkBalance() public view returns(uint balance) {
        return balances[msg.sender];
    }
    
    function checkLockTime() public view returns(uint) {
        return lockTime[msg.sender];
    }
    
    function getContractBalance() public view isOwner() returns(uint contractBalance) {
        return address(this).balance;
    }
    
    fallback() external payable {
            address addr = implementation;
        
            assembly {
                calldatacopy(0, 0, calldatasize())
                let result := delegatecall(gas(), addr, 0, calldatasize(), 0, 0)
                returndatacopy(0, 0, returndatasize())
                switch result
                case 0 { revert(0, returndatasize()) }
                default { return(0, returndatasize()) }
            }
     }
 
     
        
     receive() external payable {
            emit ValueReceived(msg.sender, msg.value);
     }
    
    
}