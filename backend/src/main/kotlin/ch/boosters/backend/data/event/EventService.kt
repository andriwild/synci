package ch.boosters.backend.data.event

import org.springframework.stereotype.Service

@Service
class EventService(
   private val eventRepository: EventRepository
) {
    fun clearTables(): Boolean {
        return eventRepository.clearTable()
    }
}
