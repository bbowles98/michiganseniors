package com.template.states

import com.template.contracts.VoteContract
import net.corda.core.contracts.BelongsToContract
import net.corda.core.contracts.ContractState
import net.corda.core.identity.AbstractParty
import net.corda.core.identity.Party

// *********
// * State *
// *********
@BelongsToContract(VoteContract::class)
class VoteState(
        val host: Party,
        val issue: Int,
        val choice: Int
        ) : ContractState{
     override val participants: List<AbstractParty> = listOf(host)
}
