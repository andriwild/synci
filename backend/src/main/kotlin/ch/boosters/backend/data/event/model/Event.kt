package ch.boosters.backend.data.event.model

import java.time.LocalDateTime


data class Event(val name: String, val id: String, val startsOn: LocalDateTime, val endsOn: LocalDateTime?)
