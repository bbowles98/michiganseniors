package com.template.flows

import co.paralleluniverse.fibers.Suspendable
import com.template.contracts.VoteContract
import com.template.states.VoteState
import net.corda.core.contracts.Command
import net.corda.core.contracts.requireThat
import net.corda.core.flows.*
import net.corda.core.identity.Party
import net.corda.core.transactions.SignedTransaction
import net.corda.core.transactions.TransactionBuilder
import net.corda.core.utilities.ProgressTracker

// *********
// * Flows *
// *********
@InitiatingFlow
@StartableByRPC
class VoteFlow(val otherParty: Party,
                val issueVal: Int,
               val choiceVal: Int
              ) : FlowLogic<Unit>() {

    /** The progress tracker provides checkpoints indicating the progress of the flow to observers. */
    override val progressTracker = ProgressTracker()

    /** The flow logic is encapsulated within the call() method. */
    @Suspendable
    override fun call() {
        // We retrieve the notary identity from the network map.
        // every time a state is consumed, its noted in the notary to take care of double voting
        val notary = serviceHub.networkMapCache.notaryIdentities[0]

        // We create the transaction components.
        val outputState = VoteState(ourIdentity, otherParty, issueVal, choiceVal)
        val command = VoteContract.Commands.Create()
//        val command = Command(VoteContract.Commands.Action(), ourIdentity.owningKey)

        // We create a transaction builder and add the components.
        val txBuilder = TransactionBuilder(notary = notary)
                .addOutputState(outputState, VoteContract.ID)
                .addCommand(command, ourIdentity.owningKey)

        // We sign the transaction.
        val signedTx = serviceHub.signInitialTransaction(txBuilder)

        // Creating a session with the other party.
        val otherPartySession = initiateFlow(otherParty)

        // We finalise the transaction and then send it to the otherParty.
        subFlow(FinalityFlow(signedTx, otherPartySession))
    }
}

@InitiatedBy(VoteFlow::class)
class VoteFlowResponder(val otherPartySession: FlowSession) : FlowLogic<Unit>() {
    @Suspendable
    override fun call() {
        subFlow(ReceiveFinalityFlow(otherPartySession))
    }
}
