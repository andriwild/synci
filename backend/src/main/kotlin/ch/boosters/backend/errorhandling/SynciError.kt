package ch.boosters.backend.errorhandling

import arrow.core.Either

sealed class SynciError(val message: String)

class DatabaseError(message: String): SynciError(message)
class ElementNotFound(message: String): SynciError(message)
class InvalidUser(message: String): SynciError(message)

typealias SynciEither<A> = Either<SynciError, A>