//
// File:    Reporting.sol
// Purpose: Reporting functions, for web application and audit
//
// Course:	DAT5002 Blockchain Fundamentals
// Authors:	Tom Rowan, ST20285213
//          Adam Riley, ST20317308
//          Diamond Johnson, ST20316205
// Ref:     DAT5002_S1_25
// Tutor:   Dr. Ali Shahaab

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.3 <0.9.0;

import "./4-PentestPhase.sol";

contract Reporting is PentestPhase {

    //
    // Data Structures for Reporting
    //

    // View struct for customer summary reporting
    struct CustomerSummary {
        address customer_address;
        string  name;
        uint    rfp_count;
        uint    total_budget_committed;
    }

    // View struct for pentester summary reporting
    struct PentesterSummary {
        address pentester_address;
        string  name;
        uint    total_bids;
        uint    wins;
        uint    total_earnings;
    }

    // View struct for bid details
    struct BidView {
        address bidder;
        string  bidder_name;
        uint    bid_value;
        string  response_doc_url;
    }

    // View struct for RFP with bid details
    struct RFPWithBids {
        uint        rfp_id;
        address     customer;
        address     winning_bidder;
        uint        max_budget;
        uint        winning_bid;
        uint        bidding_end_datetime;
        uint        bid_count;
        uint        bidder_count;
        string      title;
        string      rfp_doc_url;
        RFPState    state;
        BidView[]   bids;
    }

    // View struct for pentester's bid history
    struct PentesterBidHistory {
        uint    rfp_id;
        string  rfp_title;
        uint    bid_value;
        uint    winning_bid;
        address winning_bidder;
        bool    won;
        RFPState    state;
    }

    //
    // Owner Only Reporting Functions
    //

    // Title: listAllRFPs
    // Type: External View
    // Purpose: List all detail of all RFPs (minus the bids)
    // Can be run by: Owner
    // Requires: N/A
    function listAllRFPs() 
      external view onlyOwner 
      returns (RFPView[] memory) 
    {
        RFPView[] memory views = new RFPView[](rfp_count);

        for (uint i = 0; i < rfp_count; i++) {
            views[i] = RFPView({
                customer: rfps[i].customer,
                winning_bidder: rfps[i].winning_bidder,
                max_budget: rfps[i].max_budget,
                winning_bid: rfps[i].winning_bid,
                bidding_end_datetime: rfps[i].bidding_end_datetime,
                bid_count: rfps[i].bid_count,
                bidder_count: rfps[i].bidder_count,
                title: rfps[i].title,
                rfp_doc_url: rfps[i].rfp_doc_url,
                state: rfps[i].state
            });
        }

        return views;
    }

    // Title: listTopCustomers
    // Type: External View
    // Purpose: List all customers with their RFP counts and total budgets committed
    // Can be run by: Owner
    // Requires: N/A
    // Note: Returns customers in order they were encountered in RFPs, not sorted
    //       Sorting should be done off-chain by the consuming application
    function listTopCustomers(address[] calldata _customer_addresses) 
      external view onlyOwner 
      returns (CustomerSummary[] memory) 
    {
        CustomerSummary[] memory summaries = new CustomerSummary[](_customer_addresses.length);

        for (uint i = 0; i < _customer_addresses.length; i++) {
            address addr = _customer_addresses[i];
            uint totalBudget = 0;

            // Calculate total budget committed across all customer RFPs
            uint[] memory custRfps = customer_rfps[addr];
            for (uint j = 0; j < custRfps.length; j++) {
                totalBudget += rfps[custRfps[j]].max_budget;
            }

            summaries[i] = CustomerSummary({
                customer_address: addr,
                name: customers[addr],
                rfp_count: customer_rfpCount[addr],
                total_budget_committed: totalBudget
            });
        }

        return summaries;
    }

    // Title: listTopPentesters
    // Type: External View
    // Purpose: List all pentesters with their bid activity and earnings
    // Can be run by: Owner
    // Requires: N/A
    // Note: Sorting should be done off-chain by the consuming application
    function listTopPentesters(address[] calldata _pentester_addresses) 
      external view onlyOwner 
      returns (PentesterSummary[] memory) 
    {
        PentesterSummary[] memory summaries = new PentesterSummary[](_pentester_addresses.length);

        for (uint i = 0; i < _pentester_addresses.length; i++) {
            address addr = _pentester_addresses[i];
            uint totalBids = 0;
            uint wins = 0;

            // Count bids and wins across all RFPs
            for (uint j = 0; j < rfp_count; j++) {
                if (rfps[j].bids[addr].bid_value > 0) {
                    totalBids++;
                    if (rfps[j].winning_bidder == addr) {
                        wins++;
                    }
                }
            }

            summaries[i] = PentesterSummary({
                pentester_address: addr,
                name: pentesters[addr],
                total_bids: totalBids,
                wins: wins,
                total_earnings: pentester_cash_made[addr]
            });
        }

        return summaries;
    }

    // Title: getMarketplaceStats
    // Type: External View
    // Purpose: Get overall marketplace statistics
    // Can be run by: Owner
    // Requires: N/A
    function getMarketplaceStats() 
      external view onlyOwner 
      returns (
        uint total_rfps,
        uint total_fees_collected,
        uint current_balance,
        uint current_fee_percentage,
        uint current_minimum_budget
      ) 
    {
        return (
            rfp_count,
            owner_fees_made,
            address(this).balance,
            management_fee,
            minimum_rfp_budget
        );
    }

    //
    // Customer Only Reporting Functions
    //

    // Title: viewOwnRFPs
    // Type: External View
    // Purpose: View all RFPs owned by the calling customer with full details
    // Can be run by: Customers
    // Requires: N/A
    function viewOwnRFPs() 
      external view onlyValidCustomer 
      returns (RFPView[] memory) 
    {
        uint[] memory custRfpIds = customer_rfps[msg.sender];
        RFPView[] memory views = new RFPView[](custRfpIds.length);

        for (uint i = 0; i < custRfpIds.length; i++) {
            uint rfpId = custRfpIds[i];
            views[i] = RFPView({
                customer: rfps[rfpId].customer,
                winning_bidder: rfps[rfpId].winning_bidder,
                max_budget: rfps[rfpId].max_budget,
                winning_bid: rfps[rfpId].winning_bid,
                bidding_end_datetime: rfps[rfpId].bidding_end_datetime,
                bid_count: rfps[rfpId].bid_count,
                bidder_count: rfps[rfpId].bidder_count,
                title: rfps[rfpId].title,
                rfp_doc_url: rfps[rfpId].rfp_doc_url,
                state: rfps[i].state
            });
        }

        return views;
    }

    // Title: viewOwnRFPWithBids
    // Type: External View
    // Purpose: View a specific RFP owned by the customer with all bid details
    // Can be run by: Customer who owns the RFP
    // Requires: Valid RFP ID, caller must own the RFP
    function viewOwnRFPWithBids(uint _rfp_id) 
      external view 
      onlyValidCustomer
      onlyValidRFPId(_rfp_id) 
      onlyRFPBelongsToCustomer(_rfp_id)
      returns (
        RFPView memory rfp_details,
        BidView[] memory bid_details
      ) 
    {
        // Build RFP view
        rfp_details = RFPView({
            customer: rfps[_rfp_id].customer,
            winning_bidder: rfps[_rfp_id].winning_bidder,
            max_budget: rfps[_rfp_id].max_budget,
            winning_bid: rfps[_rfp_id].winning_bid,
            bidding_end_datetime: rfps[_rfp_id].bidding_end_datetime,
            bid_count: rfps[_rfp_id].bid_count,
            bidder_count: rfps[_rfp_id].bidder_count,
            title: rfps[_rfp_id].title,
            rfp_doc_url: rfps[_rfp_id].rfp_doc_url,
            state: rfps[_rfp_id].state
        });

        // Build bid views
        uint bidderCount = rfps[_rfp_id].bidder_count;
        bid_details = new BidView[](bidderCount);

        for (uint i = 0; i < bidderCount; i++) {
            address bidder = rfps[_rfp_id].bidder_list[i];
            bid_details[i] = BidView({
                bidder: bidder,
                bidder_name: pentesters[bidder],
                bid_value: rfps[_rfp_id].bids[bidder].bid_value,
                response_doc_url: rfps[_rfp_id].bids[bidder].response_doc_url
            });
        }

        return (rfp_details, bid_details);
    }

    // Title: viewBudgetCommitted
    // Type: External View
    // Purpose: View total budget committed by the calling customer across all their RFPs
    // Can be run by: Customers
    // Requires: N/A
    function viewBudgetCommitted() 
      external view onlyValidCustomer 
      returns (
        uint total_rfps,
        uint total_budget_committed,
        uint total_in_active_bidding,
        uint total_in_testing,
        uint total_completed
      ) 
    {
        uint[] memory custRfpIds = customer_rfps[msg.sender];
        uint totalBudget = 0;
        uint activeBidding = 0;
        uint inTesting = 0;
        uint completed = 0;

        for (uint i = 0; i < custRfpIds.length; i++) {
            uint rfpId = custRfpIds[i];
            totalBudget += rfps[rfpId].max_budget;

            if (rfps[rfpId].state == RFPState.Completed || rfps[rfpId].state == RFPState.Closed) {
                completed += rfps[rfpId].max_budget;
             } else if (rfps[rfpId].state == RFPState.WorkPhase) {
                inTesting += rfps[rfpId].max_budget;
            } else {
                activeBidding += rfps[rfpId].max_budget;
            }
        }

        return (
            custRfpIds.length,
            totalBudget,
            activeBidding,
            inTesting,
            completed
        );
    }

    // Title: viewCustomerRFPSummary
    // Type: External View
    // Purpose: Get a summary count of RFPs by status for the calling customer
    // Can be run by: Customers
    // Requires: N/A
    function viewCustomerRFPSummary() 
      external view onlyValidCustomer 
      returns (
        uint total_rfps,
        uint rfps_in_bidding,
        uint rfps_in_testing,
        uint rfps_completed,
        uint rfps_with_no_bids
      ) 
    {
        uint[] memory custRfpIds = customer_rfps[msg.sender];
        uint inBidding = 0;
        uint inTesting = 0;
        uint completedCount = 0;
        uint noBids = 0;

        for (uint i = 0; i < custRfpIds.length; i++) {
            uint rfpId = custRfpIds[i];

            if (rfps[rfpId].state == RFPState.Completed || rfps[rfpId].state == RFPState.Closed) {
                completedCount++;
                 // Check if it was a no-bid completion (Closed state)
                if (rfps[rfpId].state == RFPState.Closed) {
                    noBids++;
                }
            } else if (rfps[rfpId].state == RFPState.WorkPhase) {
                inTesting++;
            } else {
                inBidding++;
            }
        }

        return (
            custRfpIds.length,
            inBidding,
            inTesting,
            completedCount,
            noBids
        );
    }

    //
    // Pentester Only Reporting Functions
    //

    // Title: viewWinningBids
    // Type: External View
    // Purpose: View all RFPs where the calling pentester won the bid
    // Can be run by: Pentesters
    // Requires: N/A
    function viewWinningBids() 
      external view onlyValidPentester 
      returns (PentesterBidHistory[] memory) 
    {
        // First pass: count winning bids
        uint winCount = 0;
        for (uint i = 0; i < rfp_count; i++) {
            if (rfps[i].winning_bidder == msg.sender) {
                winCount++;
            }
        }

        // Second pass: populate array
        PentesterBidHistory[] memory wins = new PentesterBidHistory[](winCount);
        uint index = 0;

        for (uint i = 0; i < rfp_count; i++) {
            if (rfps[i].winning_bidder == msg.sender) {
                wins[index] = PentesterBidHistory({
                    rfp_id: i,
                    rfp_title: rfps[i].title,
                    bid_value: rfps[i].bids[msg.sender].bid_value,
                    winning_bid: rfps[i].winning_bid,
                    winning_bidder: rfps[i].winning_bidder,
                    won: true,
                    state: rfps[i].state
                });
                index++;
            }
        }

        return wins;
    }

    // Title: viewLosingBids
    // Type: External View
    // Purpose: View all RFPs where the calling pentester bid but did not win
    // Can be run by: Pentesters
    // Requires: N/A
    function viewLosingBids() 
      external view onlyValidPentester 
      returns (PentesterBidHistory[] memory) 
    {
        // First pass: count losing bids (bid placed, bidding complete, not winner)
        uint lossCount = 0;
        for (uint i = 0; i < rfp_count; i++) {
            if (rfps[i].bids[msg.sender].bid_value > 0 && 
                rfps[i].state != RFPState.Bidding && 
                rfps[i].winning_bidder != msg.sender) {
                lossCount++;
            }
        }

        // Second pass: populate array
        PentesterBidHistory[] memory losses = new PentesterBidHistory[](lossCount);
        uint index = 0;

        for (uint i = 0; i < rfp_count; i++) {
            if (rfps[i].bids[msg.sender].bid_value > 0 && 
                rfps[i].state != RFPState.Bidding && 
                rfps[i].winning_bidder != msg.sender) {
                losses[index] = PentesterBidHistory({
                    rfp_id: i,
                    rfp_title: rfps[i].title,
                    bid_value: rfps[i].bids[msg.sender].bid_value,
                    winning_bid: rfps[i].winning_bid,
                    winning_bidder: rfps[i].winning_bidder,
                    won: false,
                    state: rfps[i].state
                });
                index++;
            }
        }

        return losses;
    }

    // Title: viewActiveBids
    // Type: External View
    // Purpose: View all RFPs where the calling pentester has an active bid (bidding not complete)
    // Can be run by: Pentesters
    // Requires: N/A
    function viewActiveBids() 
      external view onlyValidPentester 
      returns (PentesterBidHistory[] memory) 
    {
        // First pass: count active bids
        uint activeCount = 0;
        for (uint i = 0; i < rfp_count; i++) {
            if (rfps[i].bids[msg.sender].bid_value > 0 && rfps[i].state == RFPState.Bidding) {
                activeCount++;
            }
        }

        // Second pass: populate array
        PentesterBidHistory[] memory active = new PentesterBidHistory[](activeCount);
        uint index = 0;

        for (uint i = 0; i < rfp_count; i++) {
            if (rfps[i].bids[msg.sender].bid_value > 0 && rfps[i].state == RFPState.Bidding) {
                active[index] = PentesterBidHistory({
                    rfp_id: i,
                    rfp_title: rfps[i].title,
                    bid_value: rfps[i].bids[msg.sender].bid_value,
                    winning_bid: 0,  // Not determined yet
                    winning_bidder: address(0),  // Not determined yet
                    won: false,  // Not determined yet
                    state: RFPState.Bidding
                });
                index++;
            }
        }

        return active;
    }

    // Title: viewAllMyBids
    // Type: External View
    // Purpose: View all bids placed by the calling pentester (active, won, and lost)
    // Can be run by: Pentesters
    // Requires: N/A
    function viewAllMyBids() 
      external view onlyValidPentester 
      returns (PentesterBidHistory[] memory) 
    {
        // First pass: count all bids
        uint bidCount = 0;
        for (uint i = 0; i < rfp_count; i++) {
            if (rfps[i].bids[msg.sender].bid_value > 0) {
                bidCount++;
            }
        }

        // Second pass: populate array
        PentesterBidHistory[] memory allBids = new PentesterBidHistory[](bidCount);
        uint index = 0;

        for (uint i = 0; i < rfp_count; i++) {
            if (rfps[i].bids[msg.sender].bid_value > 0) {
                bool didWin = rfps[i].winning_bidder == msg.sender;
                allBids[index] = PentesterBidHistory({
                    rfp_id: i,
                    rfp_title: rfps[i].title,
                    bid_value: rfps[i].bids[msg.sender].bid_value,
                    winning_bid: rfps[i].winning_bid,
                    winning_bidder: rfps[i].winning_bidder,
                    won: didWin,
                    state: rfps[i].state
                });
                index++;
            }
        }

        return allBids;
    }

    // Title: viewPentesterEarnings
    // Type: External View
    // Purpose: View earnings summary for the calling pentester
    // Can be run by: Pentesters
    // Requires: N/A
    function viewPentesterEarnings() 
      external view onlyValidPentester 
      returns (
        uint total_earnings,
        uint total_wins,
        uint total_bids,
        uint pending_payments
      ) 
    {
        uint wins = 0;
        uint bids = 0;
        uint pending = 0;

        for (uint i = 0; i < rfp_count; i++) {
            if (rfps[i].bids[msg.sender].bid_value > 0) {
                bids++;
                if (rfps[i].winning_bidder == msg.sender) {
                    wins++;
                    // If in WorkPhase state, payment is pending
                    if (rfps[i].state == RFPState.WorkPhase) {
                        pending += rfps[i].winning_bid;
                    }
                }
            }
        }

        return (
            pentester_cash_made[msg.sender],
            wins,
            bids,
            pending
        );
    }

    //
    // General Reporting Functions (Any Registered Entity)
    //

    // Title: getRFPDetails
    // Type: External View
    // Purpose: Get details of a specific RFP (without bids)
    // Can be run by: Any registered customer or pentester
    // Requires: Valid RFP ID
    function getRFPDetails(uint _rfp_id) 
      external view 
      onlyValidEntity
      onlyValidRFPId(_rfp_id) 
      returns (RFPView memory) 
    {
        return RFPView({
            customer: rfps[_rfp_id].customer,
            winning_bidder: rfps[_rfp_id].winning_bidder,
            max_budget: rfps[_rfp_id].max_budget,
            winning_bid: rfps[_rfp_id].winning_bid,
            bidding_end_datetime: rfps[_rfp_id].bidding_end_datetime,
            bid_count: rfps[_rfp_id].bid_count,
            bidder_count: rfps[_rfp_id].bidder_count,
            title: rfps[_rfp_id].title,
            rfp_doc_url: rfps[_rfp_id].rfp_doc_url,
            state: rfps[_rfp_id].state
        });
    }

    // Title: getMyBidForRFP
    // Type: External View
    // Purpose: Get the calling pentester's bid for a specific RFP
    // Can be run by: Pentesters
    // Requires: Valid RFP ID
    function getMyBidForRFP(uint _rfp_id) 
      external view 
      onlyValidPentester
      onlyValidRFPId(_rfp_id) 
      returns (
        uint bid_value,
        string memory response_doc_url,
        bool has_bid
      ) 
    {
        uint bidValue = rfps[_rfp_id].bids[msg.sender].bid_value;
        return (
            bidValue,
            rfps[_rfp_id].bids[msg.sender].response_doc_url,
            bidValue > 0
        );
    }

    // Title: getTotalRFPCount
    // Type: External View
    // Purpose: Get the total number of RFPs in the system
    // Can be run by: Any registered customer or pentester
    // Requires: N/A
    function getTotalRFPCount() 
      external view 
      onlyValidEntity
      returns (uint) 
    {
        return rfp_count;
    }

}




