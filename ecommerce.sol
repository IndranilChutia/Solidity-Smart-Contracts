//SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0 <0.9.0;

contract Ecommerce {
    
    // Creating a structure of the product
    struct Product{
        string title;
        string desc;
        address payable seller;
        uint256 productId;
        uint256 price;
        address buyer;
        bool delivered;
    }


    //Manager Account
    address payable public manager;

    // The contract deployer will become the manager and call certain functions
    constructor(){
        manager = payable(msg.sender);
    }


    //Contract Destroy Check, All functions will only work if destroyed == false.
    bool destroyed = false;

    modifier isNotDestroyed{
        require(!destroyed, "Contract does not exist");
        _;
    }


    //Event Declaration
    event registered(string title, uint productId, address seller);
    event bought(uint productId, address buyer);
    event delivered(uint productId);




    // Counter to keep track of the productID
    uint256 counter = 1;

    // Creating a list of products
    Product[] public products;



    //Register a product function
    function registerProduct(string memory _title, string memory _desc, uint _price) public isNotDestroyed{
        require(_price>0, "Enter a valid price");
        Product memory tempProduct;
        tempProduct.title = _title;
        tempProduct.desc = _desc;
        tempProduct.price = _price * (10**18);
        tempProduct.seller = payable(msg.sender);
        tempProduct.productId = counter;
        products.push(tempProduct);
        counter++;
        emit registered(_title, tempProduct.productId, msg.sender);
    }


    //Buying a product function
    function buy(uint256 _productId) payable public isNotDestroyed{
        require(products[_productId - 1].price == msg.value, "Please pay the exact price");
        require(products[_productId - 1].seller != msg.sender, "Seller cannot buy the same product");

        products[_productId-1].buyer=msg.sender;

        emit bought(_productId, msg.sender);
    }


    //Confirm Delivery and ether transfer to seller function
    function delivery(uint _productId) public isNotDestroyed{
        require(products[_productId - 1].buyer == msg.sender, "Only buyer can confirm delivery");
        products[_productId - 1].delivered = true;
        products[_productId - 1].seller.transfer(products[_productId - 1].price);

        emit delivered(_productId);
    
    }


    //Destroy Smart Contract Function

        // function destroy() public{
        //     require(msg.sender==manager, "restriced action");
        //     selfdestruct(manager); //This can lead to ether loss as the functions will still be available to call 
        // }


    // This destroy function is efficient as it blocks all the function from getting called
    function destroy() public isNotDestroyed{
        require(manager==msg.sender);
        manager.transfer(address(this).balance); //Sends all the contract ether balance to Manager after the contract is destroyed
        destroyed=true;
    }


    //If the contract is destroyed, fallback will make sure that if anyone
    //sends ether to the contract address it doesn't gets lost and returns back to the sender
    fallback() payable external{
        payable(msg.sender).transfer(msg.value);
    }
}
