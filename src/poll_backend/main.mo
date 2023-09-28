import Text "mo:base/Text";
import RBTree "mo:base/RBTree";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";
import Array "mo:base/Array";

actor {
    var question : Text = "What is your best programming language?";

    // Stable entry for upgrades
    stable var entries : [(Nat, [(Text, Nat)])] = [];

    var questions = RBTree.RBTree<Nat, Text>(Nat.compare);
    questions.put(1, "What is your best programming language?");
    questions.put(2, "What is your best AI tool?");

    var votes = RBTree.RBTree<Text, Nat>(Text.compare);
    var qVotes = RBTree.RBTree<Nat, RBTree.RBTree<Text, Nat>>(Nat.compare);

    public query func getQuestions(questionId: Nat) : async ?Text {
        questions.get(questionId)
    };

    public query func getVotes() : async [(Nat, [(Text, Nat)])] {
        var qAs = Buffer.Buffer<(Nat, [(Text, Nat)])>(RBTree.size(qVotes.share()));
        for(item in qVotes.entries()) {
            var tup: (Nat, [(Text, Nat)]) = (item.0, Iter.toArray(item.1.entries()));
            qAs.add(tup);
        };
        Buffer.toArray(qAs)
    };

    public func vote(questionId: Nat, entry : Text) : async [(Text, Nat)] {
        let qVote: ?RBTree.RBTree<Text, Nat> = qVotes.get(questionId);
        // https://internetcomputer.org/docs/current/motoko/main/errors
        // https://internetcomputer.org/docs/current/motoko/main/base/RBTree#function-size
        // https://internetcomputer.org/docs/current/tutorials/developer-journey/level-2/2.1-storage-persistence
        let votes_for_entry : ?Nat = votes.get(entry);
        let current_votes_for_entry : Nat = switch votes_for_entry {
            case null 0;
            case (?Nat) Nat;
        };
        votes.put(entry, current_votes_for_entry + 1);
        Iter.toArray(votes.entries());
    };

    public func resetVotes() : async [(Text, Nat)] {
        votes.put("Motoko", 0);
        votes.put("Rust", 0);
        votes.put("TypeScript", 0);
        votes.put("Python", 0);
        Iter.toArray(votes.entries());
    };

    system func preupgrade() {
        entries := Iter.toArray(votes.entries());
    };

    system func postupgrade() {
        for(item in entries.vals()) {
            votes.put(item.0, item.1);
        };
        entries := [];
    };
};
