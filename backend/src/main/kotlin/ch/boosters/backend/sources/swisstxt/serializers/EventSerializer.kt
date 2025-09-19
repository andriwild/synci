package ch.boosters.backend.sources.swisstxt.serializers

import ch.boosters.backend.sources.swisstxt.model.SwissTxtEvent
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.decodeFromJsonElement
import org.springframework.stereotype.Service

@Service
class EventSerializer(private val json: Json) {

    internal fun parseResponse(eventsJsonString: String): SwissTxtEvent {
        val eventsJson = json.parseToJsonElement(eventsJsonString)
        return json.decodeFromJsonElement<SwissTxtEvent>(eventsJson)
    }
}