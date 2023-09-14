import Text "mo:base/Text";
import RBTree "mo:base/RBTree";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";

actor {
    var question: Text = "What is your favorite programming language?";

    var votes: RBTree.RBTree<Text, Nat> = RBTree.RBTree(Text.compare);

    public query func getQuestion() : async Text {
        question
    };

    public query func getVotes() : async [(Text, Nat)] {
        Iter.toArray(votes.entries())
    };

    public func vote(entry: Text) : async [(Text, Nat)] {
        let votes_for_entry :?Nat = votes.get(entry);
        let current_votes_for_entry : Nat = switch votes_for_entry {
            case null 0;
            case (?Nat) Nat;
        };
        votes.put(entry, current_votes_for_entry + 1);
        Iter.toArray(votes.entries())
    };

    public func resetVotes() : async [(Text, Nat)] {
        votes.put("Motoko", 0);
        votes.put("Rust", 0);
        votes.put("TypeScript", 0);
        votes.put("Python", 0);
        Iter.toArray(votes.entries())
    };
};
