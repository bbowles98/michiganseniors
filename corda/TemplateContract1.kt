package com.template.contracts

import com.template.states.VoteState
import net.corda.core.contracts.CommandData
import net.corda.core.contracts.Contract
import net.corda.core.contracts.requireSingleCommand
import net.corda.core.contracts.requireThat
import net.corda.core.transactions.LedgerTransaction
// ************
// * Contract *
// ************
class VoteContract : Contract {
    companion object {
        // Used to identify our contract when building a transaction.
        const val ID = "com.template.contracts.VoteContract"
    }

    // A transaction is valid if the verify() function of the contract of all the transaction's input and output states
    // does not throw an exception.
    override fun verify(tx: LedgerTransaction) {
        // Verification logic goes here.

        val command =tx.commands.requireSingleCommand<Commands>().value

        when(command){
            is Commands.Issue -> requireThat{
                "There should be no input state" using (tx.inputs.isEmpty())
                "There should be one input state" using (tx.outputs.size == 1)
                "The output state must be of type VoteState" using (tx.outputs.get(0).data is VoteState)
                val outputState = tx.outputs.get(0).data as VoteState
            }
        }

    }

    // Used to indicate the transaction's intent.
    interface Commands : CommandData {
        class Issue : Commands
    }
}