package com.example.schema

import net.corda.core.contracts.UniqueIdentifier
import net.corda.core.identity.Party
import net.corda.core.schemas.MappedSchema
import net.corda.core.schemas.PersistentState
import java.util.*
import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.Table

/**
 * The family of schemas for VoteState.
 */
object VoteSchema

/**
 * An VoteState schema.
 */
object VoteSchemaV1 : MappedSchema(
        schemaFamily = VoteSchema.javaClass,
        version = 1,
        mappedTypes = listOf(PersistentVote::class.java)) {
    @Entity
    @Table(name = "vote_states")
    class PersistentVote(
            @Column(name = "Election")
            val Election: String,

            @Column(name = "Voter")
            val Voter: String,

            @Column(name = "Issue")
            val Issue: Int,

            @Column(name = "Selection")
            val Selection: Int,

            @Column(name = "Id")
            val Id: UUID
    ) : PersistentState() {
        // Default constructor required by hibernate.
        constructor(): this("", "", 0, 0, UUID.randomUUID())
    }
}