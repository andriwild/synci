package ch.boosters.backend.sources.formulaone

import ch.boosters.backend.sources.formulaone.model.FormulaOneEvent
import kotlinx.serialization.json.*
import org.springframework.stereotype.Service

@Service
class FormulaOneSerializer (
    private val json: Json
){
    internal fun parseResponse(jsonString: String): List<FormulaOneEvent> {
        val eventJson = json.parseToJsonElement(jsonString)
        val events = json.decodeFromJsonElement<List<FormulaOneEvent>>(getEvents(eventJson))
        return events
    }

    private fun getEvents(json: JsonElement): JsonElement {
        val events = json
            .jsonObject["races"]
        return events ?: JsonNull
    }

}