package ch.boosters.backend.errorhandling

import arrow.core.Either

inline fun <A> Either.Companion.safeDbOp(
    block: () -> A
): Either<DatabaseError, A> =
    catch(block).mapLeft { it -> DatabaseError(it.message ?: "An unexpected error on database level happened. This is the stack trace: ${it.stackTrace}")}