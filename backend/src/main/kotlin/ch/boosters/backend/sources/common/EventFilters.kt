package ch.boosters.backend.sources.common

import ch.boosters.backend.data.event.model.BaseEvent
import java.time.LocalDateTime

/** Only events that start after [now]; past games are never stored. */
fun <T : BaseEvent> List<T>.futureOnly(now: LocalDateTime = LocalDateTime.now()): List<T> =
    filter { it.startsOn.isAfter(now) }
