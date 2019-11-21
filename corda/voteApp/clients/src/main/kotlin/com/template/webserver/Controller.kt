package com.template.webserver

import com.template.IOUState
import net.corda.core.contracts.StateAndRef
import net.corda.core.messaging.vaultQueryBy
import org.slf4j.LoggerFactory
import org.springframework.http.MediaType
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController


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




    // receiving a vote
    @GetMapping(value = "/votes", produces = arrayOf(MediaType.APPLICATION_JSON_VALUE))
    fun storeVote() : ResponseEntity<List<StateAndRef<IOUState>>> {
        return ResponseEntity.ok(proxy.vaultQueryBy<IOUState>().states)
    }

    @PostMapping(value = "create-iou", produces = arrayOf("text/plain"), headers = arrayOf("Content-Type=application/x-www-form-urlencoded"))
    fun createIOU(request: HttpServletRequest): ResponseEntity<String> {
        val iouValue = request.getParameter("iouValue").toInt()
        val partyName = request.getParameter("partyName")
        return partyName
//        if(partyName == null){
//            return ResponseEntity.badRequest().body("Query parameter 'partyName' must not be null.\n")
//        }
//        if (iouValue <= 0 ) {
//            return ResponseEntity.badRequest().body("Query parameter 'iouValue' must be non-negative.\n")
//        }
//        val partyX500Name = CordaX500Name.parse(partyName)
//        val otherParty = proxy.wellKnownPartyFromX500Name(partyX500Name) ?: return ResponseEntity.badRequest().body("Party named $partyName cannot be found.\n")
//
//        return try {
//            val signedTx = proxy.startTrackedFlow(::Initiator, iouValue, otherParty).returnValue.getOrThrow()
//            ResponseEntity.status(HttpStatus.CREATED).body("Transaction id ${signedTx.id} committed to ledger.\n")
//
//        } catch (ex: Throwable) {
//            logger.error(ex.message, ex)
//            ResponseEntity.badRequest().body(ex.message!!)
//        }
    }


}