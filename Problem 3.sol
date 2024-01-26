// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >=0.7.0 <0.9.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract loanservice {              //Smart contract for a loan prividing service with guarantor and accepting payments in NFTs
    uint256 public loanNum;         //Number of loans recorded   

    constructor() {
        loanNum = 0;
    }

    //Structures
    struct NFTOffers{               //Structure of initiation of NFTs for payment transfers
        address NFTContract;        //Transfer of ownership
        uint256 tokenID;
        uint256 offeredPrice;       //Value of NFT
        bool Accepted;              //To check decision of lendor
    }

    struct requestLoan{             //Structure to request and submit a loan
        uint256 loanID;
        uint256 loanAmt;            //Net Loan Amount
        uint256 interest;           //Net interest
        address payable lendor;
        uint256 lendorInterest;     //Interest demanded by lendor
        address payable borrower;   //Address/ID of borrower
        address payable guarantor;  //Address/ID of guarantor
        bool guaranteed;            //Check if loan has a gurantor or not
        uint256 interestPaid;       //Current amount of interest paid
        uint256 reqDate;            //Date on which loan was requested
        uint256 lapseDate;          //Date on which loan gets lapsed
        NFTOffers NFTProposal;      //Variable for NFT transfers
    }

    struct guaranteeOffer{          //Structure of proposal signed by the guarantor
        address payable guarantor;
        address payable borrower;
        uint256 loanAmt;
        uint256 interestLimit;      //Amount of interest to be paid to guarantor
    }

    //Mappings
    mapping (uint256 => address) public borrowers;                  //Mapping for iteration of other mappings
    mapping (address => requestLoan) public loanRequests;           //Mapping for request of loans
    mapping (address => guaranteeOffer) public guaranteeOffers;     //Mapping for received offers of guarantee
    
    //Modifiers 
    modifier checkLR_Existing(address borrowerAddress) {            //Loan request validation for existence
        require (loanRequests[borrowerAddress].borrower != address(0), "This loan request does not exist");
        _;
    }

    modifier checkLR_NotExisting(address borrowerAddress) {         //Loan request validation for non-existence
        require (loanRequests[borrowerAddress].borrower == address(0), "This loan request already exists");
        _; 
    }
    
    modifier checkLR_Notguaranteed(address borrowerAddress) {       //Loan request validation for guarantee
        require(loanRequests[borrowerAddress].guaranteed == false, "This loan request is already guaranteed" );
        _; 
    }

    modifier checkLR_NotConfirmed(address borrowerAddress) {        //Loan request validation of record checking
        require(loanRequests[borrowerAddress].lendor == address(0), "This loan request is already confirmed" );
        _;
    }

    modifier checkCaller_NotBorrower(address borrowerAddress) {    //Validation to withdraw access for Borrower address
        require(loanRequests[borrowerAddress].borrower != msg.sender, "Invalid Request - Borrower cannot access" );
        _;
    }

    modifier checkCaller_Borrower(address borrowerAddress) {       //Validation to check if Borrower is the invoker
        require(loanRequests[borrowerAddress].borrower == msg.sender, "Invalid Request - Only Borrower can access" );
        _;
    }
        
    modifier checkCaller_NotGuarantor(address borrowerAddress){    //Validation to withdraw access for Guarantor address
        require(loanRequests[borrowerAddress].guarantor != msg.sender, "Invalid Request - Guarantor cannot access" );
        _;

    }

    modifier checkCaller_Lendor(address borrowerAddress){           //Validation to check if Lendor is the invoker
        require(loanRequests[borrowerAddress].guarantor != msg.sender, "Invalid Request - Only Lendor can access" );
        _;

    }

    modifier checkAmountTransferred(address borrowerAddress){       //Validation to confirm total loan amount to be transferred
        require((msg.value)/1000000000000000 == loanRequests[borrowerAddress].loanAmt, "Enter the exact loan amount");
        _;
    }

    modifier checkGuaranteeOffer_Exists(address guarantorAddress){  //Validation to check if a Guarantor exists
        require(guaranteeOffers[guarantorAddress].guarantor != address(0), "guarantee Proposal doesnt exist");
        _;
    }

    modifier checkGuarantor_Exists(address guarantorAddress){       //Validation of Guarantor himself
        require(guaranteeOffers[guarantorAddress].borrower == msg.sender, "Invalid Guarantor");
        _;

    }

    modifier checkLR_Confirmed(address borrowerAddress){             //To check approval status of loan request
        require(loanRequests[borrowerAddress].lendor != address(0), "This loan request has not been approved" );
        _;
    }

    modifier checkLR_Guaranteed(address borrowerAddress){           //To check if the loan request is guaranteed
        require(loanRequests[borrowerAddress].guarantor != address(0), "This loan request has not been guaranteed" );
        _;
    }

    //Events
    event newLoanReq(address borrower, uint256 loanNum, uint256 loanAmt, uint256 interest, uint256 reqDate, uint256 lapseDate); //Registration event of new loan request
    event guaranteeOfferEvent(address borrower, uint256 interestLimit);                                                         //Registration event of Guarantee offer
    event confirmGuaranteeEvent(address guarantor, bool approve);                                                               //Confirmation event of registered guarantee

    //Functions
    function reqLoan(uint256 loanAmt, uint256 lapseDate, uint256 interest) public               //Function to request a loan
    checkLR_NotExisting(msg.sender) 
    {
        loanNum++;
        borrowers[loanNum] = msg.sender;
        loanRequests[msg.sender].borrower = payable(msg.sender);                                //Borrower address
        loanRequests[msg.sender].loanID = loanNum;                                              //Loan number
        loanRequests[msg.sender].interest = interest;                                           //Interest amount
        loanRequests[msg.sender].loanAmt = loanAmt;                                             //Total loan amount
        loanRequests[msg.sender].lapseDate = lapseDate;                                         //Lapse date of loan
        loanRequests[msg.sender].reqDate = block.timestamp;                                     //Requested date of loan
        loanRequests[msg.sender].guaranteed = false;                                            //Guaranteed or not
        emit newLoanReq(msg.sender, loanNum, loanAmt, interest, loanRequests[msg.sender].reqDate, loanRequests[msg.sender].lapseDate); //New loan request registration event
    }

    function guaranteeLoan(uint256 interestLimit, address borrowerAddress) public payable       //Funtion to register guarantee for loan
    checkLR_Existing(borrowerAddress)
    checkLR_Notguaranteed(borrowerAddress)
    checkLR_NotConfirmed(borrowerAddress)
    checkCaller_NotBorrower(borrowerAddress)
    checkAmountTransferred(borrowerAddress)
    {
        guaranteeOffers[msg.sender].borrower = loanRequests[borrowerAddress].borrower;          //Guarantor update to the specific loan request
        guaranteeOffers[msg.sender].guarantor = payable(msg.sender);
        guaranteeOffers[msg.sender].interestLimit = interestLimit;
        guaranteeOffers[msg.sender].loanAmt = msg.value;
        
        emit guaranteeOfferEvent(borrowerAddress, interestLimit);                               //New guarantee registration event
    }

    function confirmGuarantee(address guarantorAddress, bool approve) public                    //Function to approve guarantee
    checkLR_Existing(msg.sender)
    checkLR_Notguaranteed(msg.sender)   
    checkLR_NotConfirmed(msg.sender)
    checkCaller_Borrower(msg.sender)
    checkGuaranteeOffer_Exists(guarantorAddress)
    checkGuarantor_Exists(guarantorAddress)
    {
        if (approve) {
            loanRequests[msg.sender].guarantor = payable(guarantorAddress);                     //If approved, guaranter gets registered
            loanRequests[msg.sender].lendorInterest = loanRequests[msg.sender].interest - guaranteeOffers[guarantorAddress].interestLimit; //Calculation of lendor's interest amount
            loanRequests[msg.sender].guaranteed = true;                                         //Registration state is changed to confirmed
        } else {
            uint256 value = guaranteeOffers[guarantorAddress].loanAmt;                          
            delete(guaranteeOffers[guarantorAddress]);                                          //Registration record is deleted
            payable(guarantorAddress).transfer(value);
        }

        emit confirmGuaranteeEvent(guarantorAddress, approve);                                  //Confirm guarantee registration event
    }

    function viewAllLoanRequests() public view returns(requestLoan[] memory){                   //Function to view existing loan requests
        requestLoan[] memory requestsArray = new requestLoan[](loanNum);
        for(uint i=0; i<loanNum; i++){                                                          //Iterating through the array
            requestsArray[i] = loanRequests[borrowers[i+1]];
        }
        return requestsArray;                                                                   
    }

    function viewLoanRequest(address borrowerAddress) public view                               //Function to view particular loan request
    checkLR_Existing(borrowerAddress) 
    returns(requestLoan memory)                                                                 
    {
        return(loanRequests[borrowerAddress]);                                          
    }

    function giveLoan(address borrowerAddress) public payable                                   //Function to provide the loan 
    checkLR_Existing(borrowerAddress)
    checkLR_Guaranteed(borrowerAddress)
    checkLR_NotConfirmed(borrowerAddress)
    checkCaller_NotBorrower(borrowerAddress)
    checkCaller_NotGuarantor(borrowerAddress)
    checkAmountTransferred(borrowerAddress)

    {
        loanRequests[borrowerAddress].lendor = payable(msg.sender);     
        loanRequests[borrowerAddress].interestPaid = 0;
        loanRequests[borrowerAddress].lapseDate = block.timestamp + (loanRequests[borrowerAddress].lapseDate * 86400); //Calculating lapse date in terms of timstamp
        loanRequests[borrowerAddress].borrower.transfer(msg.value);
    }
    
    function offerNFT(address NFTContract, uint256 tokenID, uint256 price) public           //Funtion to provide an NFT
    checkLR_Existing(loanRequests[msg.sender].borrower)            
    checkLR_Confirmed(loanRequests[msg.sender].borrower)
    checkCaller_Borrower(loanRequests[msg.sender].borrower)
    {   
        require(loanRequests[msg.sender].NFTProposal.NFTContract == address(0), "NFT Offer already exists"); //To check for existing NFT offer
        ERC721 nft = ERC721(NFTContract);
        require(nft.ownerOf(tokenID) == msg.sender, "Access denied! You are not the owner");
        loanRequests[msg.sender].NFTProposal.NFTContract = NFTContract;                     //Registration of NFT
        loanRequests[msg.sender].NFTProposal.tokenID = tokenID;                             
        loanRequests[msg.sender].NFTProposal.offeredPrice = price;
        loanRequests[msg.sender].NFTProposal.Accepted = false;
        nft.setApprovalForAll(loanRequests[msg.sender].lendor, true);                       //Confirmation of approval
    }

    function approveNFTOffers(address borrowerAddress, bool approve) public                 //Function to approve the NFT offers
    checkLR_Existing(loanRequests[msg.sender].borrower)
    checkLR_Confirmed(loanRequests[msg.sender].borrower)
    checkCaller_Lendor(loanRequests[msg.sender].borrower)
    {   
        require(loanRequests[msg.sender].NFTProposal.NFTContract != address(0), "NFT offer does not exist"); 
        ERC721 nft = ERC721(loanRequests[borrowerAddress].NFTProposal.NFTContract);
        if(approve){                                                                        //If approved, the balance amount will be changed to NFT
            
            uint256 balanceAmount = (loanRequests[borrowerAddress].loanAmt + loanRequests[borrowerAddress].interest) - loanRequests[borrowerAddress].NFTProposal.offeredPrice ;
            
            if (balanceAmount == 0){                                                        //Stores variables required for NFT transfer locally
                uint256 tokenID = loanRequests[borrowerAddress].NFTProposal.tokenID ;       //Transfer of NFT 
                delete(guaranteeOffers[loanRequests[borrowerAddress].guarantor]);
                delete(loanRequests[borrowerAddress]);                                      
                nft.safeTransferFrom(borrowerAddress, msg.sender, tokenID);
            }
            else{
                loanRequests[borrowerAddress].interestPaid += loanRequests[borrowerAddress].NFTProposal.offeredPrice; //Else interest amount increases
            }
        }
        else{
            loanRequests[borrowerAddress].NFTProposal.NFTContract = address(0);             //Goes back to initial state
            loanRequests[borrowerAddress].NFTProposal.tokenID = 0;
            loanRequests[borrowerAddress].NFTProposal.offeredPrice = 0;
            loanRequests[borrowerAddress].NFTProposal.Accepted = false;
        }
    }

    function receiveLoan() public payable                                                    //Function to settle the loan amount
    checkLR_Existing(msg.sender)
    checkLR_Confirmed(msg.sender)
    checkCaller_Borrower(msg.sender)
    {  
        require(((msg.value/1000000000000000) <= (loanRequests[msg.sender].loanAmt + loanRequests[msg.sender].interest) && msg.value > 0), "Enter valid interest amount" );
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

    function getGuarantee(address borrowerAddress) public                                   //In case lendor requests guarantee amount upon failure of repayment      
    checkLR_Existing(borrowerAddress)
    checkLR_Confirmed(borrowerAddress)
    checkCaller_Lendor(borrowerAddress)
    {
        require(loanRequests[borrowerAddress].lapseDate <= block.timestamp, "Loan Date has not lapsed yet!!"); //To check Lapse Date

        uint256 balanceLoanAmount = (loanRequests[borrowerAddress].loanAmt) * 1000000000000000;
        delete(guaranteeOffers[loanRequests[borrowerAddress].guarantor]);
        delete(loanRequests[borrowerAddress]);
        payable(msg.sender).transfer(balanceLoanAmount);
    }

}