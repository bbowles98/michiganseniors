package com.template.contracts

import net.corda.core.contracts.CommandData
import net.corda.core.contracts.Contract
import net.corda.core.transactions.LedgerTransaction
import net.corda.core.contracts.*
import com.template.states.VoteState


// ************
// * Contract *
// ************
class VoteContract : Contract {
    companion object {
        // Used to identify our contract when building a transaction.
        const val ID = "com.template.contracts.VoteContract"
    }

    // Our Create command.
    class Create : CommandData

    override fun verify(tx: LedgerTransaction) {
        val command = tx.commands.requireSingleCommand<Create>()

        requireThat {
            // Constraints on the shape of the transaction.
            "No inputs should be consumed when issuing a vote" using (tx.inputs.isEmpty())
            "There should be one output state of type VoteState" using (tx.outputs.size == 1)


            val output = tx.outputsOfType<VoteState>().single()
            "The votevalue must be non-negative." using (output.choice > 0)
        }
    }

    // Used to indicate the transaction's intent.
    interface Commands : CommandData {
        class Action : Commands
    }
}