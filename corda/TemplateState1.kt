package com.template.states


import com.template.contracts.VoteContract
import net.corda.core.contracts.BelongsToContract
import net.corda.core.contracts.ContractState
import net.corda.core.contracts.UniqueIdentifier
import net.corda.core.identity.AbstractParty
import net.corda.core.identity.Party

// *********
// * State *
// *********
@BelongsToContract(VoteContract::class)
data class VoteState(
        val election: UniqueIdentifier,
        val user: Party,
        val issue: String,
        val selection: String
) : ContractState {
    override val participants: List<AbstractParty> = listof(user);
}
