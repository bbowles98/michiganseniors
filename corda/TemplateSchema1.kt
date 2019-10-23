package com.template.states


import com.template.contracts.VoteContract
import net.corda.core.contracts.BelongsToContract
import net.corda.core.contracts.ContractState
import net.corda.core.contracts.UniqueIdentifier
import net.corda.core.identity.AbstractParty
import net.corda.core.identity.Party


@CordaSerializable
object SchemaV1 : MappedSchema(schemaFamily = Schema::class.java, version = 1, mappedTypes = listOf(PersistentParentToken::class.java, PersistentChildToken::class.java)) {

    @Entity
    @Table(name = "parent_data")
    class PersistentParentToken(
            @Column(name = "owner")
            var owner: String,

            @Column(name = "issuer")
            var issuer: String,

            // vote is 0 or 1
            @Column(name = "vote")
            var vote: Boolean,

            @Column(name = "linear_id")
            var linear_id: UUID,

            // transactionID that will be sent back to use to verify vote
            @JoinColumns(JoinColumn(name = "transaction_id", referencedColumnName = "transaction_id"), JoinColumn(name = "output_index", referencedColumnName = "output_index"))

            var listOfPersistentChildTokens: MutableList<PersistentChildToken>
    ) : PersistentState()
    @Entity
    @CordaSerializable
    @Table(name = "child_data")
    class PersistentChildToken(
            @Id
            var Id: UUID = UUID.randomUUID(),

            @Column(name = "owner")
            var owner: String,

            @Column(name = "issuer")
            var issuer: String,

            @Column(name = "vote")
            var vote: Boolean,

            @Column(name = "linear_id")
            var linear_id: UUID,

            @ManyToOne(targetEntity = PersistentParentToken::class)
            var persistentParentToken: TokenState

    ) : PersistentState()
}