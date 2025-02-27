package ch.boosters.backend.sources.fotmob.model

import kotlinx.serialization.*
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

@Serializable(with = FotMobEventSerializer::class)
data class FotMobEvent(
    val name: String,
    val id: Int,
    @Contextual val startsOn: LocalDateTime,
    @Contextual val endsOn: LocalDateTime,
    val homeId: String,
    val awayId: String
)

object FotMobEventSerializer : KSerializer<FotMobEvent> {
    override val descriptor: SerialDescriptor = buildClassSerialDescriptor("Event") {
        element<String>("name")
        element<Int>("id")
        element<String>("startsOn")
        element<String>("endsOn")
    }

    override fun deserialize(decoder: Decoder): FotMobEvent {
        val jsonInput = decoder as? JsonDecoder ?: throw SerializationException("This serializer can be used only with JSON")
        val jsonObject = jsonInput.decodeJsonElement().jsonObject

        val home = jsonObject["home"]?.jsonObject?.get("name")?.jsonPrimitive?.content ?: ""
        val homeId = jsonObject["home"]?.jsonObject?.get("id")?.jsonPrimitive?.content ?: ""
        val away = jsonObject["away"]?.jsonObject?.get("name")?.jsonPrimitive?.content ?: ""
        val awayId = jsonObject["away"]?.jsonObject?.get("id")?.jsonPrimitive?.content ?: ""
        val name = "$home - $away"

        val id = jsonObject["id"]?.jsonPrimitive?.content?.toIntOrNull() ?: throw SerializationException("Invalid id")

        val utcTime = jsonObject["status"]?.jsonObject?.get("utcTime")?.jsonPrimitive?.content
            ?: throw SerializationException("Missing utcTime")

        val formatter = DateTimeFormatter.ISO_DATE_TIME
        val startsOn = LocalDateTime.parse(utcTime, formatter)
        val endsOn = startsOn.plusHours(2)

        return FotMobEvent(name, id, startsOn, endsOn, homeId, awayId)
    }

    override fun serialize(encoder: Encoder, value: FotMobEvent) {
        // Implement if needed
        throw NotImplementedError("Serialization is not implemented")
    }
}
