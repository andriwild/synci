package ch.boosters.backend.errorhandling

import arrow.core.Either

sealed class SynciError(val message: String)

class DatabaseError(message: String): SynciError(message)
class ElementNotFound(message: String): SynciError(message)
class InvalidUser(message: String): SynciError(message)
/** The caller is authenticated but not allowed to perform the action (403). */
class Forbidden(message: String): SynciError(message)
/** The request violates a business rule, e.g. the last admin leaving an organisation (400). */
class InvalidRequest(message: String): SynciError(message)

typealias SynciEither<A> = Either<SynciError, A>
