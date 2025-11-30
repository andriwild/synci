package ch.boosters.backend.data.event.model

import ch.boosters.backend.data.team.Gender
import ch.boosters.backend.sources.swisstxt.model.SwissTxtTeamEventSerializer
import kotlinx.serialization.Contextual
import kotlinx.serialization.Serializable
import java.time.LocalDateTime

sealed interface BaseEvent {
    val id: String
    val startsOn: LocalDateTime
    val endsOn: LocalDateTime?
}

@Serializable
data class Event(
    override val id: String,
    val name: String,
    @Contextual override val startsOn: LocalDateTime,
    @Contextual override val endsOn: LocalDateTime? = null,
): BaseEvent

@Serializable(with = SwissTxtTeamEventSerializer::class)
data class TeamEvent(
    override val id: String,
    @Contextual override val startsOn: LocalDateTime,
    @Contextual override val endsOn: LocalDateTime? = null,
    val homeId: String,
    val homeName: String,
    val awayId: String,
    val awayName: String,
    val gender: Gender
    ): BaseEvent