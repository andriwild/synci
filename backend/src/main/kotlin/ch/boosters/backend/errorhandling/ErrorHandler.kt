package ch.boosters.backend.errorhandling

import org.slf4j.LoggerFactory
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity

object ErrorHandler {
    private val logger = LoggerFactory.getLogger(ErrorHandler::class.java)

    fun handle(error: SynciError): ResponseEntity<String> = when (error) {
        is DatabaseError -> {
            logger.error("Database error: {}", error.message)
            ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("An internal error occurred")
        }
        is ElementNotFound -> {
            logger.info("Not found: {}", error.message)
            ResponseEntity.status(HttpStatus.NOT_FOUND).body("The requested element was not found: ${error.message}")
        }
        is InvalidUser ->
            ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Could not find the requested resource for the given user. ${error.message}")
    }
}
