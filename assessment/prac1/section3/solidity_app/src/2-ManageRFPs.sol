//
// File:    ManageRFPs.sol
// Purpose: Management of Request for Proposals
//
// Course:	DAT5002 Blockchain Fundamentals
// Authors:	Tom Rowan, ST20285213
//          Adam Riley, ST20317308
//          Diamond Johnson, ST20316205
// Ref:     DAT5002_S1_25
// Tutor:   Dr. Ali Shahaab

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.3 <0.9.0;

import "./1-PentestMarketplace.sol";

// Base contract for bidding on pentesting engagements
contract ManageRFPs is PentestMarketplace {

    //
    // Define events
    //

    event log_newRFP (address customer, uint rfp_id, string title);     

    //
    // Modifiers
    //

    // Purpose: Check whether the address calling the function is the customer owns the RFP
    modifier onlyRFPBelongsToCustomer(uint _rfp_id) {
        require(RFPBelongsToCustomer(_rfp_id, msg.sender), "Caller is not the customer for this RFP");
        _;
    }

    //
    // Functions
    //

    // Title: createRFP 
    // Type: External
    // Purpose: Allows customers to create an RFP.
    // Can be run by: Customers
    // Requires: User sends a "Max Budget" value. User pays (Max Budget + Marketplace Fees) along with the function call.
    function createRFP ( uint _max_budget, uint _bidding_end_datetime, string memory _title, string memory _rfp_doc_url) 
        external payable onlyValidCustomer hasSentEnough(_max_budget) 
        {

        // Add the struct data
        rfps[rfp_count].customer = msg.sender;
        rfps[rfp_count].winning_bidder = address(0);
        rfps[rfp_count].max_budget = _max_budget;
        rfps[rfp_count].bidding_end_datetime = _bidding_end_datetime;
        rfps[rfp_count].winning_bid = 0;
        rfps[rfp_count].title = _title;
        rfps[rfp_count].rfp_doc_url = _rfp_doc_url;
        rfps[rfp_count].state = RFPState.Bidding;

        // Emit event with index of the newly created RFP
        emit log_newRFP(msg.sender, rfp_count, _title);

        // Increase RFP counter for this customer
        customer_rfpCount[msg.sender]++;

        // Add this RPF index number to the customer's list of RFPs
        customer_rfps[msg.sender].push(rfp_count);

        // Increment the rfp Counter
        rfp_count++;        
    }

    // Title: RFPBelongsToCustomer 
    // Type: Internal
    // Purpose: Check whether an RFP id belongs to a specific customer addresse
    // Can be run by: Anyone
    // Requires: N/A
    function RFPBelongsToCustomer(uint _rfp_id, address _customer) 
      internal view onlyValidRFPId (_rfp_id) 
      returns (bool) 
      {
        return rfps[_rfp_id].customer == _customer;
    }

    // Title: listCustomerRFPIndexes
    // Type: External
    // Purpose: List the RFPs that belong to a specific customer address
    // Can be run by: Customers or pentesters
    // Requires: N/A
    function listCustomerRFPIndexes(address _customer) 
      external view
      onlyValidEntity()
      returns (uint[] memory) 
      {
        return customer_rfps[_customer];
    }

    // Title: listCustomerRFPwithTitles
    // Type: External
    // Purpose: List the RFPs that belong to a specific customer address, with titles
    // Can be run by: Customers or pentesters
    // Requires: N/A
    function listCustomerRFPsWithTitles(address _customer) 
      external view 
      onlyValidEntity()
      returns (uint[] memory, string[] memory) 
      {
        uint[] memory ids = customer_rfps[_customer];
        string[] memory titles = new string[](ids.length);

        // Build lists to return. External web app must parse these out.
        for (uint i = 0; i < ids.length; i++) {
            titles[i] = rfps[ids[i]].title;
        }
        return (ids, titles);
    }

    // Title: listCustomerRFPsWithDetail
    // Type: External
    // Purpose: List the RFPs that belong to a specific customer address, with more details
    // Can be run by: Customers or pentesters
    // Requires: N/A
    function listCustomerRFPsWithDetail(address _customer) 
      external view 
      onlyValidEntity()
      returns (uint[] memory, string[] memory,string[] memory, uint[] memory, uint[] memory) 
      {
        uint[] memory ids = customer_rfps[_customer];
        string[] memory titles = new string[](ids.length);
        string[] memory urls = new string[](ids.length);
        uint[] memory bidding_end_time = new uint[](ids.length);
        uint[] memory max_budget = new uint[](ids.length);

        // Build lists to return. External web app must parse these out.
        for (uint i = 0; i < ids.length; i++) {
            titles[i] = rfps[ids[i]].title;
            urls[i] = rfps[ids[i]].rfp_doc_url;
            bidding_end_time[i] = rfps[ids[i]].bidding_end_datetime;
            max_budget[i] = rfps[ids[i]].max_budget;
        }
        return (ids, titles, urls, bidding_end_time, max_budget);
    }


} // End Contract
