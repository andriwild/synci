package ch.boosters.backend.errorhandling

sealed class SynciError(val message: String)

class DatabaseError(message: String): SynciError(message)
class ElementNotFound(message: String): SynciError(message)