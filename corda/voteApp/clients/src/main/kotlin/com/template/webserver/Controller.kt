package com.template.webserver

import com.template.IOUState
import com.template.VoteFlow
import net.corda.core.contracts.StateAndRef
import net.corda.core.identity.CordaX500Name
import net.corda.core.identity.Party
import net.corda.core.messaging.startFlow
import net.corda.core.messaging.startTrackedFlow
import net.corda.core.messaging.vaultQueryBy
import net.corda.core.utilities.getOrThrow
import org.slf4j.LoggerFactory
import org.springframework.http.HttpStatus
import org.springframework.http.MediaType
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import javax.servlet.http.HttpServletRequest


/**
 * Define your API endpoints here.
 */
@RestController
@RequestMapping("") // The paths for HTTP requests are relative to this base path.
class Controller(rpc: NodeRPCConnection) {

    companion object {
        private val logger = LoggerFactory.getLogger(RestController::class.java)
    }

    private val proxy = rpc.proxy

    @GetMapping(value = "/home", produces = arrayOf("text/plain"))
    private fun test(): String {
        return "Alabama, Arkansas I sure love my maw and paw, but not the way that I do love you"
    }

    // register?




    // return all votes!!!!!!
    @GetMapping(value = "/votes", produces = arrayOf(MediaType.APPLICATION_JSON_VALUE))
    fun storeVote() : ResponseEntity<List<StateAndRef<IOUState>>> {
        return ResponseEntity.ok(proxy.vaultQueryBy<IOUState>().states)
    }

    //receive a vote
    @PostMapping(value = "/put", produces = arrayOf("text/plain"), headers = arrayOf("Content-Type=application/x-www-form-urlencoded"))
    fun createIOU(request: HttpServletRequest): ResponseEntity<String> {
        val issueVal = request.getParameter("issueVal").toInt()
        val selectionVal = request.getParameter("selectionVal").toString()
        val partyName = request.getParameter("electionVal")
        val voterName = "O=Voter,L=New York,C=US"
        val electionID = request.getParameter("electionID")

        if (issueVal < 0 || selectionVal < 0 ) {
            return ResponseEntity.badRequest().body("Query parameters must be non-negative.\n")
        }
        val partyX500Name = CordaX500Name.parse(partyName)
        val partyX501Name = CordaX500Name.parse(voterName)

        val otherParty = proxy.wellKnownPartyFromX500Name(partyX500Name) ?: return ResponseEntity.badRequest().body("Party named $partyName cannot be found.\n")
        val otherParty2 = proxy.wellKnownPartyFromX500Name(partyX501Name) ?: return ResponseEntity.badRequest().body("Party named $voterName cannot be found.\n")
        return try {
            val signedTx = proxy.startTrackedFlow(::VoteFlow, issueVal, selectionVal, electionID, otherParty, otherParty2).returnValue.getOrThrow()
            ResponseEntity.status(HttpStatus.CREATED).body("Congrats u voted.\n")

        } catch (ex: Throwable) {
            logger.error(ex.message, ex)
            ResponseEntity.badRequest().body(ex.message!!)
        }
    }


}