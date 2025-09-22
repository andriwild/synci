package ch.boosters.backend.sources.swisstxt.model

import ch.boosters.backend.data.event.model.Event
import kotlinx.serialization.KSerializer
import kotlinx.serialization.Serializable
import kotlinx.serialization.SerializationException
import kotlinx.serialization.descriptors.SerialDescriptor
import kotlinx.serialization.descriptors.buildClassSerialDescriptor
import kotlinx.serialization.descriptors.element
import kotlinx.serialization.encoding.Decoder
import kotlinx.serialization.encoding.Encoder
import kotlinx.serialization.json.JsonDecoder
import kotlinx.serialization.json.contentOrNull
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter


@Serializable(with = SwissTxtEventSerializer::class)
data class SwissTxtEvent(
    val id: Int,
    val name: String,
    val events: List<Event>,
)

object SwissTxtEventSerializer : KSerializer<SwissTxtEvent> {
    override val descriptor: SerialDescriptor = buildClassSerialDescriptor("Event") {
        element<Int>("id")
        element<String>("name")
        element<List<Event>>("events")
    }

    override fun deserialize(decoder: Decoder): SwissTxtEvent {
        val jsonInput = decoder as? JsonDecoder ?: throw SerializationException("This serializer can be used only with JSON")
        val formatter = DateTimeFormatter.ISO_DATE_TIME

        val jsonObject = jsonInput.decodeJsonElement().jsonObject
        val id         = jsonObject["id"]?.jsonPrimitive?.content?.toIntOrNull() ?: throw SerializationException("Invalid id")
        val name       = jsonObject["displayName"]?.jsonPrimitive?.content ?: throw SerializationException("Invalid name")
        val events     = jsonObject["phases"]
            ?.jsonArray?.mapNotNull { phaseElement ->
                var displayName = phaseElement.jsonObject["displayName"]?.jsonPrimitive?.content  ?: throw SerializationException("Invalid name")
                val id          = phaseElement.jsonObject["id"]?.jsonPrimitive?.content  ?: throw SerializationException("Invalid id")
                val location    = phaseElement.jsonObject["event"]?.jsonObject?.get("name")?.jsonPrimitive?.content
                val utcTime     = phaseElement.jsonObject["dateInfo"]
                    ?.jsonObject?.get("startDate")
                    ?.jsonObject?.get("fullDateTime")?.jsonPrimitive?.contentOrNull
                    ?: throw SerializationException("Invalid date info")
                val startsOn  = LocalDateTime.parse(utcTime, formatter)

                // Some sports have a dedicated location property
                if(!location.isNullOrBlank()) {
                    displayName = "$displayName - $location"
                }
               Event(id, "$name: $displayName", startsOn)
            } ?: emptyList()
        return SwissTxtEvent(id, name, events)
    }

    override fun serialize(encoder: Encoder, value: SwissTxtEvent) {
        // Implement if needed
        throw NotImplementedError("Serialization is not implemented")
    }
}