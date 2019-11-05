package com.template.contracts

import net.corda.core.contracts.CommandData
import net.corda.core.contracts.Contract
import net.corda.core.transactions.LedgerTransaction
import net.corda.core.contracts.*
import com.template.states.VoteState


// ************
// * Contract *
// ************
// contract checks whether proposed transactions are valid
class VoteContract : Contract {
    companion object {
        // Used to identify our contract when building a transaction.
        const val ID = "com.template.contracts.VoteContract"
    }
    // commands are used to know intent of a transaction
    // nodes(parties) use transactions to update the ledger

    // each transaction must be signed by issuer/host

    // Our Create command.
    class Create : CommandData

    // Our Register command.
    class Register : CommandData


    // contact validates the transaction
    override fun verify(tx: LedgerTransaction) {
        val command = tx.getCommand<Commands>
        val input = tx.inputsOfType<VoteState>.singleOrNull()
        val output = tx.outputsOfType<VoteState>().single()

        when (command.value) {
            is Commands.Register -> {
                // contract requirements when registering in an election
                // implement voter authentication/registration for MVP
                requireThat{
                }
            }

            is Commands.Create -> {
                //contract requirements when voting in election
                requireThat{
                    // Constraints on the shape of the transaction.
                    "Should have 3 inputs " using (tx.inputs.size == 3)
                    "Input size should be the same as output size" using (tx.outputs.size == tx.inputs.size)

                    // Content constraints
                    "The votevalue must be non-negative." using (output.choice > 0)

                    // Required signer constraints
                }
            }
        }
    }

    // Used to indicate the transaction's intent.
    interface Commands : CommandData {
        class Register : Commands
        class Create : Commands
    }
}