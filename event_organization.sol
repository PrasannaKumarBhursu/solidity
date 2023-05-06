// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract eventManagement {
    struct Event {
        address manager;
        string name;
        uint date;
        uint price;
        uint ticketCount;
        uint ticketRemain;
    }
    mapping(uint => Event) public events;
    mapping(address => mapping(uint => uint)) public tickets;
    uint public nextEventId;

    function createEvent(
        string memory name,
        uint date,
        uint price,
        uint ticketCount
    ) public {
        require(
            date > block.timestamp,
            "You can organize event for future date"
        );
        require(
            ticketCount > 0,
            "You can organize event only if u create tickets more than 0 tickets"
        );
        events[nextEventId] = Event(
            msg.sender,
            name,
            date,
            price,
            ticketCount,
            ticketCount
        );
        nextEventId++;
    }

    function blockTimestamp() public view returns (uint) {
        return block.timestamp;
    }

    function check_amount() public view returns (uint) {
        return address(this).balance;
    }

    function buyTicket(uint id, uint quantity) public payable {
        require(events[id].date != 0, "Event does not exist");
        require(events[id].date > block.timestamp, "Event has already occured");
        Event storage _event = events[id];
        require(msg.value >= (_event.price * quantity), "Ether is not enough");
        require(_event.ticketRemain >= quantity, "Not enough tickets");
        _event.ticketRemain -= quantity;
        tickets[msg.sender][id] += quantity;
    }

    function transferTicket(uint id, uint quantity, address to) public {
        require(events[id].date != 0, "Event does not exist");
        require(events[id].date > block.timestamp, "Event has already occured");
        require(
            tickets[msg.sender][id] >= quantity,
            "You do not have enough tickets"
        );
        tickets[msg.sender][id] += quantity;
        tickets[to][id] -= quantity;
    }

    function transfer_money(
        address payable to,
        uint id,
        uint no_of_tickets
    ) public {
        require(
            events[id].manager == msg.sender,
            "You dont have access to this function"
        );
        require(events[id].date != 0, "Event does not exist");
        require(events[id].date > block.timestamp, "Event has already occured");
        require(
            tickets[to][id] >= no_of_tickets,
            "You do not have enough tickets"
        );
        tickets[to][id] -= no_of_tickets;
        events[id].ticketRemain += no_of_tickets;
        to.transfer(no_of_tickets * events[id].price * 10 ** 18);
    }
}
