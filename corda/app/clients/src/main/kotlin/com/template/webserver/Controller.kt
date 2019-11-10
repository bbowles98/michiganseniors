package com.template.webserver

import org.slf4j.LoggerFactory
import org.springframework.http.HttpStatus
import org.springframework.http.MediaType
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import net.corda.core.identity.CordaX500Name
import com.template.states.VoteState
import com.template.contracts.VoteContract
import net.corda.core.contracts.StateAndRef
import net.corda.core.messaging.vaultQueryBy
import net.corda.core.node.services.Vault
import javax.servlet.http.HttpServletRequest

/**
 * Define your API endpoints here.
 */
//////////////CITATION:
/////////////https://medium.com/corda/spring-cleaning-migrating-your-cordapp-away-from-the-deprecated-corda-jetty-web-server-9d618371fc92

@RestController
@RequestMapping("/") // The paths for HTTP requests are relative to this base path.
class Controller(rpc: NodeRPCConnection) {

    companion object {
        private val logger = LoggerFactory.getLogger(RestController::class.java)
    }

    private val proxy = rpc.proxy

    @GetMapping(value = "home/", produces = arrayOf("text/plain"))
    private fun templateendpoint(): String {
        return "HOME PAGE"
    }

    //Get all nodes in network
    @GetMapping(value = "peers/", produces = arrayOf(MediaType.APPLICATION_JSON_VALUE))
    fun getPeers(): Map<String, List<CordaX500Name>> {
        val nodeInfo = proxy.networkMapSnapshot()
        return mapOf("peers" to nodeInfo
                .map { it.legalIdentities.first().name })
    }

    //View all VoteStates in Node
    @GetMapping(value = "votes/", produces = arrayOf(MediaType.APPLICATION_JSON_VALUE))
    fun getVotes() : ResponseEntity<List<StateAndRef<VoteState>>> {
        return ResponseEntity.ok(proxy.vaultQueryBy<VoteState>().states)
    }
}



