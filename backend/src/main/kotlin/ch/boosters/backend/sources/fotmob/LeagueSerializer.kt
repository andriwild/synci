package ch.boosters.backend.sources.fotmob

import ch.boosters.backend.sources.common.JsonSerializerConfig
import ch.boosters.backend.sources.fotmob.model.Team
import kotlinx.serialization.json.*
import org.springframework.stereotype.Service

@Service
class LeagueSerializer(
    private val jsonSerializer: JsonSerializerConfig,
    private val json: Json
) {

    internal fun parseLeagues(leaguesJson: String): List<Team> {
        jsonSerializer.jsonSerializer()
        val teamsJson  = json.parseToJsonElement(leaguesJson)
        val teams = json.decodeFromJsonElement<List<Team>>(getTeams(teamsJson))
        return teams
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