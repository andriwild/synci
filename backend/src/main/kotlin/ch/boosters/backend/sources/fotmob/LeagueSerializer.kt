package ch.boosters.backend.sources.fotmob

import ch.boosters.backend.sources.common.JsonSerializerConfig
import ch.boosters.backend.sources.fotmob.model.Event
import ch.boosters.backend.sources.fotmob.model.Team
import kotlinx.serialization.json.*
import org.springframework.stereotype.Service

@Service
class LeagueSerializer(
    private val jsonSerializer: JsonSerializerConfig,
    private val json: Json
) {

    internal fun parseResponse(leaguesJsonString: String): Pair<List<Event>, List<Team>> {
        val leaguesJson = json.parseToJsonElement(leaguesJsonString)
        val teams = json.decodeFromJsonElement<List<Team>>(getTeams(leaguesJson))
        val events = json.decodeFromJsonElement<List<Event>>(getEvents(leaguesJson))
        return Pair(events, teams)
    }

    private fun getEvents(json: JsonElement): JsonElement {
        val events = json
            .jsonObject["matches"]
            ?.jsonObject?.get("allMatches")
        return events ?: JsonNull
    }


    private fun getTeams(json: JsonElement): JsonElement {
        val teams = json
            .jsonObject["table"]
            ?.jsonArray?.get(0)
            ?.jsonObject?.get("data")
            ?.jsonObject
            ?.get("table")
            ?.jsonObject
            ?.get("all")
        return teams ?: JsonNull
    }
}