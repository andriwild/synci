package ch.boosters.backend.sources.swissski

import ch.boosters.backend.sources.swissski.model.SwissSkiEvent
import kotlinx.serialization.json.*
import org.springframework.stereotype.Service

@Service
class RaceSerializer (
    private val json: Json
){
    internal fun parseResponse(jsonString: String): List<SwissSkiEvent> {
        val eventJson = json.parseToJsonElement(jsonString)
        val events = json.decodeFromJsonElement<List<SwissSkiEvent>>(getEvents(eventJson))
        return events
    }

    private fun getEvents(json: JsonElement): JsonElement {
        val events = json
            .jsonObject["result"]
        return events ?: JsonNull
    }

}
