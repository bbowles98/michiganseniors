package com.template.states

import com.example.schema.VoteSchemaV1
import com.template.contracts.VoteContract
import net.corda.core.contracts.BelongsToContract
import net.corda.core.contracts.ContractState
import net.corda.core.contracts.UniqueIdentifier
import net.corda.core.identity.AbstractParty
import net.corda.core.identity.AnonymousParty
import net.corda.core.identity.Party
import net.corda.core.schemas.MappedSchema
import net.corda.core.schemas.PersistentState
import net.corda.core.schemas.QueryableState
import net.corda.core.serialization.CordaSerializable


// *********
// * State *
// *********
@BelongsToContract(VoteContract::class)
@CordaSerializable
data class VoteState(val Election: Party,
                     val Voter: Party,
                     val Issue: Int,
                     val Selection: Int,
                     val Id: UniqueIdentifier
) : ContractState {
    override val participants: List<AbstractParty> = listOf(Election, Voter)
}

