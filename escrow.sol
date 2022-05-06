//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;


//The third party(deployer) will select the Payer address, payee Address and the escrow amount
//Only payer can deposit the ethers and it should be <= the amount declared by the third party
//The third party will be able to release funds. The funds will be released if contract balace == amount declared in the contract

contract Escrow {
    address payable payer;
    address payable payee;
    address thirdParty;
    uint256 amount;

    constructor(address payable _payer, address payable _payee, uint256 _amount){
        thirdParty = msg.sender;
        payer = _payer;
        payee = _payee;
        amount = _amount;
    }

    // Modifiers

    modifier payerOnly(){
        require(payer == msg.sender, "Sender must be the payer");
        _;
    }

    modifier thirdPartyOnly(){
        require(thirdParty == msg.sender, "only thirdParty can release funds");
        _;
    }


    // Functions


    function checkBalance() public view returns(uint){
        return address(this).balance/1 ether;
    }

    function deposit() payable public payerOnly{
        require(address(this).balance <= amount*1 ether, "Cant send more than escrow amount");
    }

    function release() public thirdPartyOnly{
        require(address(this).balance == amount*1 ether, "cannot release funds before full amount is sent");
        payee.transfer(address(this).balance);
    }


}
