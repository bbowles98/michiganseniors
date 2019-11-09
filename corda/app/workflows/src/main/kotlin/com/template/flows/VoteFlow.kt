package com.template.flows

import co.paralleluniverse.fibers.Suspendable
import com.template.contracts.VoteContract
import com.template.states.VoteState
import net.corda.core.contracts.Command
import net.corda.core.contracts.UniqueIdentifier
import net.corda.core.contracts.requireThat
import net.corda.core.flows.*
import net.corda.core.identity.Party
import net.corda.core.node.ServiceHub
import net.corda.core.transactions.SignedTransaction
import net.corda.core.transactions.TransactionBuilder

// *********
// * Flows *
// *********
@InitiatingFlow
@StartableByRPC
class VoteIssueInitiator(
        val Election: Party,
        val Voter: Party,
        val Issue: Int,
        val Selection: Int
) : FlowLogic<SignedTransaction>() {

    @Suspendable
    override fun call(): SignedTransaction {
        val notary = serviceHub.networkMapCache.notaryIdentities.first()
        val command = Command(VoteContract.Commands.Issue(), listOf(Election, Voter).map { it.owningKey })
        val voteState = VoteState(
                Election,
                Voter,
                Issue,
                Selection,
                UniqueIdentifier()
        )
        val txBuilder = TransactionBuilder(notary)
                .addOutputState(voteState, VoteContract.ID)
                .addCommand(command)
        txBuilder.verify(serviceHub)
        val tx = serviceHub.signInitialTransaction(txBuilder)

        val sessions = (voteState.participants - ourIdentity).map { initiateFlow(it as Party) }
        val stx = subFlow(CollectSignaturesFlow(tx, sessions))
        return subFlow(FinalityFlow(stx, sessions))
    }
}

@InitiatedBy(VoteIssueInitiator::class)
class VoteIssueResponder(val counterpartySession: FlowSession) : FlowLogic<SignedTransaction>() {
    @Suspendable
    override fun call(): SignedTransaction {
        val signedTransactionFlow = object : SignTransactionFlow(counterpartySession) {
            override fun checkTransaction(stx: SignedTransaction) = requireThat {
                val output = stx.tx.outputs.single().data
                "The output must be a VoteState" using (output is VoteState)
            }
        }
        val txWeJustSignedId = subFlow(signedTransactionFlow)
        return subFlow(ReceiveFinalityFlow(counterpartySession, txWeJustSignedId.id))
    }
}
