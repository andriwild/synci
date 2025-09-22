package ch.boosters.backend.sources.swisstxt.serializers

import ch.boosters.backend.sources.swisstxt.model.SwissTxtLeagueConfig
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.decodeFromJsonElement
import org.springframework.stereotype.Service

@Service
class LeagueSerializer(private val json: Json) {

    internal fun parseResponse(eventsJsonString: String): SwissTxtLeagueConfig {
        val eventsJson = json.parseToJsonElement(eventsJsonString)
        return json.decodeFromJsonElement<SwissTxtLeagueConfig>(eventsJson)
    }
}