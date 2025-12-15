//
// File:    BiddingPhase.sol
// Purpose: Handles Bids - creation, updates, end of bidding period
//
// Course:	DAT5002 Blockchain Fundamentals
// Authors:	Tom Rowan, ST20285213
//          Adam Riley, ST20317308
//          Diamond Johnson, ST20316205
// Ref:     DAT5002_S1_25
// Tutor:   Dr. Ali Shahaab

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.3 <0.9.0;

import "./2-ManageRFPs.sol";

contract BiddingPhase is ManageRFPs {

    //
    // Define Events
    //

    event log_newBid (address indexed pentester, uint indexed rfp_id, uint bid_value);
    event log_bidUpdated (address indexed pentester, uint indexed rfp_id, uint old_bid, uint new_bid);
    event log_biddingPeriodExtended (uint indexed rfp_id, uint old_end_time, uint new_end_time);
    event log_biddingCompleted (uint indexed rfp_id, address winning_bidder, uint winning_bid);
    event log_noBidsReceived (uint indexed rfp_id, uint refund_amount);
    event log_stateChanged (uint indexed rfp_id, RFPState old_state, RFPState new_state);

    //
    // Modifiers
    //

    // Check whether the bidding period is over. Continue if it is.
    modifier onlyBiddingPeriodOver (uint _rfp_id) {
      require(isBiddingPeriodOver(_rfp_id), "Bidding period is still active.");
      _;
    }

    // Check whether the bidding period is over. Continue if it is not.
    modifier onlyNotBiddingPeriodOver (uint _rfp_id) {
      require(!isBiddingPeriodOver(_rfp_id), "Bidding period is over.");
      _;
    }

    // Check whether the RFP is still in Bidding state
    modifier onlyInBiddingState (uint _rfp_id) {
      require(rfps[_rfp_id].state == RFPState.Bidding, "RFP is not in bidding state.");
      _;
    }

    //
    // Functions
    //

    // Title: makeBid
    // Type: External
    // Purpose: Make a bid. (This also updates a bid)
    // Can be run by: Pentesters
    // Requires: A valid RFP id, the bidding period is not over, RFP is in Bidding state
    function makeBid (uint _rfp_id, uint  _bid_value, string memory _response_doc_url) external 
      onlyValidPentester 
      onlyValidRFPId (_rfp_id) 
      onlyInBiddingState (_rfp_id)
      onlyNotBiddingPeriodOver (_rfp_id) 
      {

        // Track if this is a new bid or an update
        bool isNewBid = (rfps[_rfp_id].bids[msg.sender].bid_value == 0);
        uint oldBidValue = rfps[_rfp_id].bids[msg.sender].bid_value;

        // If the Pentester hasn't bid before, add to the list of bidders
        if (isNewBid) {
          rfps[_rfp_id].bidder_list.push(msg.sender);
          rfps[_rfp_id].bidder_count++;
        }
          
        // Set the Bid object values
        // They can only have one active bid, so it's overwritten
        rfps[_rfp_id].bids[msg.sender].bid_value = _bid_value;
        rfps[_rfp_id].bids[msg.sender].response_doc_url = _response_doc_url;
          
        // Increment number of bids --> purposefully may NOT tally with the number of bidders
        rfps[_rfp_id].bid_count++;

        // Emit appropriate event
        if (isNewBid) {
          emit log_newBid(msg.sender, _rfp_id, _bid_value);
        } else {
          emit log_bidUpdated(msg.sender, _rfp_id, oldBidValue, _bid_value);
        }
    }

    // Title: getLowestBid
    // Type: Private
    // Purpose: Get the Lowest bidder, and value of their bid
    // Can be run by: Customer who owns the RFP
    // Requires: A valid RFP id
    function getLowestBid(uint _rfp_id) 
      private view 
      onlyValidRFPId (_rfp_id) 
      returns (address, uint) 
      {
        require(rfps[_rfp_id].bid_count > 0, "RFP has no bids");

        // Set initial values for the search
        uint lowest_value = rfps[_rfp_id].max_budget;
        address lowest_bidder = address(0);

        // Loop through the bids
        for (uint i = 0; i < rfps[_rfp_id].bidder_count; i++) {

            address bidder = rfps[_rfp_id].bidder_list[i];
            uint bid_value = rfps[_rfp_id].bids[bidder].bid_value;

            if (bid_value < lowest_value) {
                lowest_value = bid_value;
                lowest_bidder = bidder;              
            }
        }
        return (lowest_bidder, lowest_value);
    }

    // Title: extendBiddingPeriod
    // Type: External
    // Purpose: Extend the bidding period
    // Can be run by: Customer who owns the RFP
    // Requires: A valid RFP id, the bidding period is not over
    function extendBiddingPeriod (uint _rfp_id, uint _new_timestamp) external 
      onlyValidRFPId (_rfp_id) 
      onlyRFPBelongsToCustomer(_rfp_id) 
      onlyNotBiddingPeriodOver (_rfp_id) 
      {
       require(block.timestamp < _new_timestamp, "New timestamp must be in the future.");    // new time must be in the future
        uint old_end_time = rfps[_rfp_id].bidding_end_datetime;
        rfps[_rfp_id].bidding_end_datetime = _new_timestamp;

            // Emit event for bidding period extension
            emit log_biddingPeriodExtended(_rfp_id, old_end_time, _new_timestamp);
      }


    // Title: markBiddingCompleted
    // Type: Private
    // Purpose: Mark the bidding process as completed, invoke return payments if no bids
    // Can be run by: Anyone
    // Requires: A valid RFP id
    function markBiddingCompleted (uint _rfp_id) 
      private 
      onlyValidRFPId (_rfp_id) 
      //onlyRFPBelongsToCustomer(_rfp_id) 
      onlyBiddingPeriodOver (_rfp_id) 
      {

        // Store old state for event logging
        RFPState oldState = rfps[_rfp_id].state;

        // If customer's RFP had bids
        if (rfps[_rfp_id].bid_count > 0) {

          (address lowest_bidder, uint lowest_value) = getLowestBid(_rfp_id);
          rfps[_rfp_id].winning_bidder = lowest_bidder;
          rfps[_rfp_id].winning_bid = lowest_value;

        // Emit event for successful bidding completion with winner
        emit log_biddingCompleted(_rfp_id, lowest_bidder, lowest_value);

        // Move to WorkPhase state (1)
        rfps[_rfp_id].state = RFPState.WorkPhase;

        // Emit state change event
        emit log_stateChanged(_rfp_id, oldState, rfps[_rfp_id].state);

        // Emit event for successful bidding completion with winner
        emit log_biddingCompleted(_rfp_id, lowest_bidder, lowest_value);
          
        // But if no bids
        } else {

          // Move to Closed state
          rfps[_rfp_id].state = RFPState.Closed;

          // Emit state change event
          emit log_stateChanged(_rfp_id, oldState, rfps[_rfp_id].state);

          // Calculate amounts
          uint fee_payable = calculateFee(rfps[_rfp_id].max_budget);
          uint returned = rfps[_rfp_id].max_budget + (fee_payable / 2);

          // Pay fees to app owner (half fee payable in this instance).
          // We took the fees into escrow up front, so we have this available in the marketplace.
          makePayment (payable(theOwner), fee_payable / 2, "Paying reduced application fee as no bids.");
          owner_fees_made += fee_payable;

          // Return the escrowed money + the other half of the fee.
          makePayment(payable(rfps[_rfp_id].customer), returned, "Escrow refund - no bids");

          // Emit event for no bids received.
          emit log_noBidsReceived(_rfp_id, rfps[_rfp_id].max_budget);

        }

    }

    // Title: biddingExpired
    // Type: Private
    // Purpose: Check if the bidding period is over, used in modifier
    // Can be run by: Anyone
    // Requires: A valid RFP id
    function isBiddingPeriodOver(uint _rfp_id) 
      onlyValidRFPId (_rfp_id)
      private view returns (bool) 
      {
        // Check whether the bidding end timeer has expired
             // If not in Bidding state, bidding is already over
        if (rfps[_rfp_id].state != RFPState.Bidding) {
          return true;
        }
        // Check whether the bidding end timer has expired
        return hasBiddingExpired(_rfp_id);
    }

    // Title: finalizeBidding
    // Type: External
    // Purpose: Called by backend server to finalize bidding after period ends
    //          Updates state to WorkPhase (1) if bids exist, or Closed (3) if no bids
    // Can be run by: Owner (backend server)
    // Requires: A valid RFP id, bidding period has expired, RFP still in Bidding state
    function finalizeBidding(uint _rfp_id) 
      external 
      nonReentrant
      onlyOwner
      onlyValidRFPId (_rfp_id)
      {
        require(rfps[_rfp_id].state == RFPState.Bidding, "RFP is not in bidding state.");
        require(hasBiddingExpired(_rfp_id), "Bidding period has not ended yet.");

        // Process the bidding completion
        markBiddingCompleted(_rfp_id);
    }

    // Title: hasbiddingExpired
    // Type: Private
    // Purpose: Check if the bidding period is over
    // Can be run by: Anyone
    // Requires: A valid RFP id
    function hasBiddingExpired(uint _rfp_id) 
      private view 
      onlyValidRFPId (_rfp_id)
      returns (bool) 
      {
        // Check whether the bidding end timeer has expired
        bool bidding_over = block.timestamp >= rfps[_rfp_id].bidding_end_datetime;
        return bidding_over;
    }


    // Title: listAllOpenRFPs
    // Type: External
    // Purpose: List all open RFPs
    // Can be run by: Pentester
    // Requires: N/A
    function listAllOpenRFPs () 
      external view
      onlyValidPentester 
      returns (uint[] memory, string[] memory, string[] memory) 
      {
        uint[] memory ids;
        string[] memory titles;
        string[] memory customer_names;
        uint[] memory expiry;

        for (uint i = 0; i < rfp_count; i++) {
          if (!hasBiddingExpired(i)) {            
            ids[i] = i;
            titles[i] = rfps[i].title;
            expiry[i] = rfps[i].bidding_end_datetime;
            customer_names[i] = customers[rfps[i].customer];
          }
        }
       return (ids, customer_names, titles);
    } 


} // End Contract
