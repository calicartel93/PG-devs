pragma solidity >=0.7.0 <0.9.0;
import "hardhat/console.sol";

contract loanservice {                          //Smart contract for a loan prividing service with guarantor
    address[] public borrowers;                 //Address of Borrowers
    uint256 public loanNum;                     //Number of loans recorded

    constructor() {
        loanNum = 0;
    }
    //Structures
    struct requestLoan{                         //Structure to request and submit a loan
        uint256 loanID;
        uint256 loanAmt;                        //Net Loan Amount
        uint256 interest;                       //Net interest
        address payable lendor;             
        uint256 lendorInterest;                 //Interest demanded by lendor
        address payable borrower;               //Address/ID of borrower
        address payable guarantor;              //Address/ID of guarantor
        bool guaranteed;                        //Check if loan has a gurantor or not
        uint256 interestPaid;                   //Current amount of interest paid
        uint256 reqDate;                        //Date on which loan was requested
        uint256 lapseDate;                      //Date on which loan gets lapsed
    }
    struct guaranteeOffer{                      //Structure of proposal signed by the guarantor
        address payable guarantor;              
        address payable borrower;
        uint256 loanAmt;
        uint256 interestLimit;                  //Amount of interest to be paid to guarantor
    }

    //Mappings
    mapping (address => requestLoan) public loanRequests;                   //Mapping for request of loans
    mapping (address => guaranteeOffer) public guaranteeOffers;             //Mapping for received offers of guarantee
    
    //Modifier
    modifier loanRequestExists {
        require (loanRequests[msg.sender].borrower == address(0), "This loan request already exists");
        _;
    }

    //Events
    event newLoanReq(address borrower, uint256 loanNum, uint256 loanAmt, uint256 interest, uint256 reqDate, uint256 lapseDate); //Registration event of new loan request
    event guaranteeOfferEvent(address borrower, uint256 interestLimit);                                                         //Registration event of Guarantee offer
    event confirmGuarenteeEvent(address guarantor, bool confirm);                                                               //Confirmation event of registered guarantee

    //Functions
    function reqLoan(uint256 loanAmt, uint256 interest, uint256 lapseDate) public loanRequestExists {       //Function to request a loan                     
        loanNum++;
        loanRequests[msg.sender].borrower = payable(msg.sender);                                            //Borrower address            
        loanRequests[msg.sender].loanID = loanNum;                                                          //Loan number
        loanRequests[msg.sender].loanAmt = loanAmt;                                                         //Total loan amount
        loanRequests[msg.sender].interest = interest;                                                       //Interest amount
        loanRequests[msg.sender].reqDate = block.timestamp;                                                 //Requested date of loan
        loanRequests[msg.sender].lapseDate = lapseDate;                                                     //Lapse date of loan
        loanRequests[msg.sender].guaranteed = false;                                                        //Guaranteed or not

        emit newLoanReq(msg.sender, loanNum, loanAmt, interest, loanRequests[msg.sender].reqDate, loanRequests[msg.sender].lapseDate);  //New loan request registration event
    }

    function guaranteeLoan(uint256 interestLimit, address borrower) public payable{                         //Funtion to register guarantee for loan
        require(loanRequests[borrower].borrower != address(0), "This loan request does not exist");         
        require(loanRequests[borrower].guaranteed == false, "This loan request is already confirmed");
        require(loanRequests[borrower].lendor == address(0), "This loan request is already recorded");
        require(loanRequests[borrower].borrower != msg.sender, "Request is invalid" );
        require(loanRequests[borrower].interest > interestLimit,"High Interest limit");
        require((msg.value)/1000000000000000 == loanRequests[borrower].loanAmt, "Enter the exact loan amount");
        guaranteeOffers[msg.sender].borrower = loanRequests[borrower].borrower;
        guaranteeOffers[msg.sender].guarantor = payable(msg.sender);
        guaranteeOffers[msg.sender].interestLimit = interestLimit;
        guaranteeOffers[msg.sender].loanAmt = msg.value;
        console.log(msg.value);
        
        emit guaranteeOfferEvent(borrower, interestLimit);                                                  //New guarantee registration event                        
    }

    function confirmGuarantee(address guarantor, bool confirm) public {                                     //Function to approve guarantee
        require(loanRequests[msg.sender].borrower != address(0), "This loan request does not exist" );      
        require(guaranteeOffers[guarantor].borrower == msg.sender, "Invalid Guarantor");
        require(guaranteeOffers[guarantor].guarantor != address(0), "Guarentee offer not found");
        require(loanRequests[msg.sender].guaranteed == false, "This loan request is already confirmed");
        require(loanRequests[msg.sender].lendor == address(0), "This loan request is already recorded");
        require(loanRequests[msg.sender].borrower == msg.sender, "Only Borrower can confirm the guarantor");
        
        if (confirm) {
            loanRequests[msg.sender].guarantor = payable(guarantor);
            loanRequests[msg.sender].lendorInterest = loanRequests[msg.sender].interest - guaranteeOffers[guarantor].interestLimit;
            loanRequests[msg.sender].guaranteed = true;
        } else {
            uint256 value = guaranteeOffers[guarantor].loanAmt;
            delete(guaranteeOffers[guarantor]);
            payable(guarantor).transfer(value);
        }

        emit confirmGuarenteeEvent(guarantor, confirm);                                                     //Confirm guarantee registration event
    }

    function viewLoanRequest(address borrowerAddress) public view returns(requestLoan memory ){             //Function to view particular loan request
        require(loanRequests[borrowerAddress].borrower != address(0), "This loan request does not exist" );
        return(loanRequests[borrowerAddress]);
    }

    function giveLoan(address borrowerAddress) public payable{                                                          //Function to provide the loan
        require(loanRequests[borrowerAddress].borrower != address(0), "This loan request does not exist" );
        require(loanRequests[borrowerAddress].lendor == address(0), "This loan request is already confirmed" );
        require(loanRequests[borrowerAddress].borrower != msg.sender, "Request is Invalid" );
        require(loanRequests[borrowerAddress].guarantor != msg.sender, "Request is Invalid" );
        require((msg.value)/1000000000000000 == loanRequests[borrowerAddress].loanAmt, "Enter the exact loan amount");

        loanRequests[borrowerAddress].lendor = payable(msg.sender);
        loanRequests[borrowerAddress].interestPaid = 0;
        loanRequests[borrowerAddress].lapseDate = block.timestamp + (loanRequests[borrowerAddress].lapseDate * 86400);  //Calculating lapse date in terms of timstamp
        loanRequests[borrowerAddress].borrower.transfer(msg.value);
    }
    
    function receiveLoan() public payable{                                                  //Function to settle the loan amount
        require(loanRequests[msg.sender].borrower != address(0), "This loan request does not exist" );
        require(loanRequests[msg.sender].lendor != address(0), "This loan request has not been approved" );
        require(loanRequests[msg.sender].borrower == msg.sender, "Only Borrower can pay interest" );
        require(((msg.value/1000000000000000) <= (loanRequests[msg.sender].loanAmt + loanRequests[msg.sender].interest) && msg.value > 0), "Interest amount is not correct" );
        console.log((loanRequests[msg.sender].loanAmt + loanRequests[msg.sender].interest));
        if(loanRequests[msg.sender].interestPaid + (msg.value/1000000000000000) < (loanRequests[msg.sender].loanAmt + loanRequests[msg.sender].interest) ){ 
            loanRequests[msg.sender].interestPaid += (msg.value/1000000000000000);          //Handling installments

        }
        else{                                                                                               
            loanRequests[msg.sender].interestPaid += (msg.value/1000000000000000);          //Handling full payment of loan
            address payable guarantor = loanRequests[msg.sender].guarantor;
            uint256 guarantorReturn = (loanRequests[msg.sender].loanAmt + guaranteeOffers[guarantor].interestLimit) * 1000000000000000;
            address payable lendor = loanRequests[msg.sender].lendor;
            uint256 lendorReturn = (loanRequests[msg.sender].loanAmt + loanRequests[msg.sender].lendorInterest) * 1000000000000000;
            delete(guaranteeOffers[guarantor]);
            delete(loanRequests[msg.sender]);
            guarantor.transfer(guarantorReturn);
            lendor.transfer(lendorReturn);
        }
        
    }

    function claimGuarantee(address borrowerAddress) public {                                                  //In case lendor requests guarantee amount upon failure of repayment
        require(loanRequests[borrowerAddress].borrower != address(0), "This loan request does not exist" );
        require(loanRequests[borrowerAddress].lendor != address(0), "This loan request is not approved" );
        require(loanRequests[borrowerAddress].lendor == msg.sender, "Only lendor can claim guarantee" );
        require(loanRequests[borrowerAddress].guarantor != address(0), "Loan is not Guaranteed" );
        require(loanRequests[borrowerAddress].lapseDate <= block.timestamp, "Loan date has not been lapsed yet!");

        uint256 balanceLoanAmount = (loanRequests[borrowerAddress].loanAmt + loanRequests[borrowerAddress].lendorInterest) * 1000000000000000;
        delete(guaranteeOffers[loanRequests[borrowerAddress].guarantor]);
        delete(loanRequests[borrowerAddress]);
        payable(msg.sender).transfer(balanceLoanAmount);
    }
}