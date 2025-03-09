package ch.boosters.backend.sources.swisstxt.model

import kotlinx.serialization.Contextual
import kotlinx.serialization.KSerializer
import kotlinx.serialization.Serializable
import kotlinx.serialization.SerializationException
import kotlinx.serialization.descriptors.SerialDescriptor
import kotlinx.serialization.descriptors.buildClassSerialDescriptor
import kotlinx.serialization.descriptors.element
import kotlinx.serialization.encoding.Decoder
import kotlinx.serialization.encoding.Encoder
import kotlinx.serialization.json.JsonDecoder
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter

@Serializable(with = SwissTxtEventSerializer::class)
data class SwissTxtEvent(
    val name: String,
    val id: Int,
    @Contextual val startsOn: LocalDateTime,
    @Contextual val endsOn: LocalDateTime,
    val homeId: String,
    val awayId: String
)

object SwissTxtEventSerializer : KSerializer<SwissTxtEvent> {
    override val descriptor: SerialDescriptor = buildClassSerialDescriptor("Event") {
        element<String>("name")
        element<Int>("id")
        element<String>("startsOn")
        element<String>("endsOn")
    }

    override fun deserialize(decoder: Decoder): SwissTxtEvent {
        val jsonInput = decoder as? JsonDecoder ?: throw SerializationException("This serializer can be used only with JSON")
        val jsonObject = jsonInput.decodeJsonElement().jsonObject
        val home = jsonObject["competitor1"]?.jsonObject?.get("name")?.jsonPrimitive?.content ?: ""
        val homeId = jsonObject["competitor1"]?.jsonObject?.get("id")?.jsonPrimitive?.content ?: ""
        val away = jsonObject["competitor2"]?.jsonObject?.get("name")?.jsonPrimitive?.content ?: ""
        val awayId = jsonObject["competitor2"]?.jsonObject?.get("id")?.jsonPrimitive?.content ?: ""
        val name = "$home - $away"

        val id = jsonObject["id"]?.jsonPrimitive?.content?.toIntOrNull() ?: throw SerializationException("Invalid id")

        val utcTime = jsonObject["dateTimeInfo"]?.jsonObject?.get("fullDateTime")?.jsonPrimitive?.content
            ?: throw SerializationException("Missing utcTime")

        val formatter = DateTimeFormatter.ISO_DATE_TIME
        val startsOn = LocalDateTime.parse(utcTime, formatter)
        val endsOn = startsOn.plusHours(2)

        return SwissTxtEvent(name, id, startsOn, endsOn, homeId, awayId)
    }

    override fun serialize(encoder: Encoder, value: SwissTxtEvent) {
        // Implement if needed
        throw NotImplementedError("Serialization is not implemented")
    }
}