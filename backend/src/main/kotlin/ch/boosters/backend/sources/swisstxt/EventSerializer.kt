package ch.boosters.backend.sources.swisstxt

import ch.boosters.backend.sources.swisstxt.model.SwissTxtEvent
import ch.boosters.backend.sources.swisstxt.model.Team
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.decodeFromJsonElement
import org.springframework.stereotype.Service

@Service
class EventSerializer(private val json: Json) {

    internal fun parseResponse(eventsJsonString: String): Pair<List<SwissTxtEvent>, List<Team>> {
        val eventsJson = json.parseToJsonElement(eventsJsonString)
        val events = json.decodeFromJsonElement<List<SwissTxtEvent>>(eventsJson)
        val teams = json.decodeFromJsonElement<List<Team>>(eventsJson)
        return Pair(events, teams)
    }
}