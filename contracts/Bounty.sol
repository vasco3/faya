pragma solidity ^0.4.8;

contract Bounty {
    address public initiator;

    struct Claim {
        address submitter;
        bytes32 ipfsHash;
        uint upVotes;
        uint downVotes;
    }

    bytes32 ipfsHash;
    uint due;
    uint reward;
    mapping (address => uint) contributions;
    Claim[] claims;

    event DepositEvent(
        address indexed _from,
        // bytes32 indexed _id,
        uint _value
    );

    event SubmitClaimEvent(
        address indexed _submitter,
        bytes32 _ipfsHash
    );

    event UpVote(
        address indexed _voter,
        uint claimIndex
    );

    event DownVote(
        address indexed _voter,
        uint claimIndex
    );

    function Bounty(address _initiator, uint _due, bytes32 _ipfsHash) {
        initiator = _initiator;

        due = _due;
        ipfsHash = _ipfsHash;
    }

    function contribute() payable {
        contributions[msg.sender] = msg.value;
        DepositEvent(msg.sender, msg.value);
    }

    function submitClaim(bytes32 _ipfsHash) {
        claims.push(Claim(msg.sender, _ipfsHash, 0, 0));
        SubmitClaimEvent(msg.sender, _ipfsHash);
    }

    function vote(uint claimIndex, bool isUpVote) {
        if (isUpVote) { 
            claims[claimIndex].upVotes += 1;
        } else {
            claims[claimIndex].downVotes += 1;
        }
    }

    function getClaimCount() returns (uint) {
        return claims.length;
    }

    function getClaimDetail(uint index) returns (address, bytes32, uint, uint) {
        var c = claims[index];
        return (c.submitter, c.ipfsHash, c.upVotes, c.downVotes);
    }

    // send reward to sender if he is the winner, and if bounty is due
    function collectReward() {
        if (block.timestamp > due) {
            var maxVotes = uint(0);
            var winner = address(0);
            for (uint i = 0; i < claims.length; i++) {
                var c = claims[i];
                var votes = c.upVotes - c.downVotes;
                if ( votes > maxVotes) {
                    winner = c.submitter;
                    maxVotes = votes;
                }
            }
            if (msg.sender == winner) {
                msg.sender.transfer(this.balance);
            }
        }
    }
}
