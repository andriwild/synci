package ch.boosters.backend.data.event

import arrow.core.Either
import ch.boosters.backend.errorhandling.SynciError
import org.springframework.stereotype.Service

@Service
class EventService(
    private val eventRepository: EventRepository
) {
    fun clearTables(): Either<SynciError, Unit> = eventRepository.clearTable()
}
