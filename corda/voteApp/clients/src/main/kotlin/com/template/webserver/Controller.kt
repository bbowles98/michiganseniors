package com.template.webserver

import com.template.IOUState
import net.corda.core.contracts.StateAndRef
import net.corda.core.messaging.vaultQueryBy
import org.slf4j.LoggerFactory
import org.springframework.http.MediaType
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
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
    private fun templateendpoint(): String {
        return "Alabama, Arkansas I sure love my maw and paw, but not the way that I do love you"
    }

    @GetMapping(value = "/votes", produces = arrayOf(MediaType.APPLICATION_JSON_VALUE))
    fun getIOUs() : ResponseEntity<List<StateAndRef<IOUState>>> {
        return ResponseEntity.ok(proxy.vaultQueryBy<IOUState>().states)
    }


}