package ch.boosters.backend.sources.swisstxt.model

import kotlinx.serialization.KSerializer
import kotlinx.serialization.Serializable
import kotlinx.serialization.SerializationException
import kotlinx.serialization.descriptors.SerialDescriptor
import kotlinx.serialization.descriptors.buildClassSerialDescriptor
import kotlinx.serialization.descriptors.element
import kotlinx.serialization.encoding.Decoder
import kotlinx.serialization.encoding.Encoder
import kotlinx.serialization.json.JsonDecoder
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive

@Serializable(with = SwissTxtLeagueSerializer::class)
data class SwissTxtLeagueConfig(
    val id: String,
    val competitorType: String?,
    val phases: List<String>
)

object SwissTxtLeagueSerializer: KSerializer<SwissTxtLeagueConfig> {
    override val descriptor: SerialDescriptor = buildClassSerialDescriptor("Event") {
        element<String>("id")
        element<String>("competitorType")
        element<List<String>>("phases")
    }

    override fun deserialize(decoder: Decoder): SwissTxtLeagueConfig {
        val jsonInput =
            decoder as? JsonDecoder ?: throw SerializationException("This serializer can be used only with JSON")

        val jsonObject     = jsonInput.decodeJsonElement().jsonObject
        val rawId          = jsonObject["id"]?.jsonPrimitive?.content?: throw SerializationException("Invalid id")
        val competitorType = jsonObject["competitorType"]?.jsonPrimitive?.content
        val phases         = jsonObject["phases"]?.jsonArray?.mapNotNull { phaseId(it.jsonObject) } ?: emptyList()
        val id             = rawId.takeIf { it.all(Char::isDigit) } ?: phases.joinToString(",")

        return SwissTxtLeagueConfig(id, competitorType, phases)
    }

    private fun phaseId(phase: JsonObject): String? {
        val ownId = phase["id"]?.jsonPrimitive?.content?.takeIf { it.isNotEmpty() }
        if (ownId != null) return ownId
        return phase["phases"]?.jsonArray
            ?.mapNotNull { phaseId(it.jsonObject) }
            ?.takeIf { it.isNotEmpty() }
            ?.joinToString(",")
    }

    override fun serialize(encoder: Encoder, value: SwissTxtLeagueConfig) {
        // Implement if needed
        throw NotImplementedError("Serialization is not implemented")
    }
}