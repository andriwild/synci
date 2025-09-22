package ch.boosters.backend.sources.swisstxt.serializers

import ch.boosters.backend.data.event.model.TeamEvent
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.decodeFromJsonElement
import org.springframework.stereotype.Service

@Service
class TeamEventSerializer(private val json: Json) {

    internal fun parseResponse(eventsJsonString: String): List<TeamEvent> {
        val eventsJson = json.parseToJsonElement(eventsJsonString)
        return json.decodeFromJsonElement<List<TeamEvent>>(eventsJson)
    }
}