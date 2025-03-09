package ch.boosters.backend.errorhandling

import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity

object ErrorHandler {
    fun handle(error: SynciError): ResponseEntity<String> = when (error) {
        is DatabaseError ->
            // TODO: add logging of error message
            ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("An internal error occurred")
        is ElementNotFound ->
            ResponseEntity.status(HttpStatus.NOT_FOUND).body("The requested element was not found: ${error.message}")
    }
}