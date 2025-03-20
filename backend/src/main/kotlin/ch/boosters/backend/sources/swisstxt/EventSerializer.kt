package ch.boosters.backend.sources.swisstxt

import ch.boosters.backend.sources.swisstxt.model.SwissTxtTeamEvent
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.decodeFromJsonElement
import org.springframework.stereotype.Service

@Service
class EventSerializer(private val json: Json) {

    internal fun parseResponse(eventsJsonString: String): List<SwissTxtTeamEvent> {
        val eventsJson = json.parseToJsonElement(eventsJsonString)
        return json.decodeFromJsonElement<List<SwissTxtTeamEvent>>(eventsJson)
    }
}