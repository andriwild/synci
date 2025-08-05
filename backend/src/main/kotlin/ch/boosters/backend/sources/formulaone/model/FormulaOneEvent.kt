package ch.boosters.backend.sources.formulaone.model

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
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter

@Serializable(with = FormulaOneEventSerializer::class)
data class FormulaOneEvent(
    val name: String,
    val id: String,
    @Contextual val raceDate: LocalDateTime,
)

object FormulaOneEventSerializer: KSerializer<FormulaOneEvent> {
    override val descriptor: SerialDescriptor = buildClassSerialDescriptor("Event") {
        element<String>("name")
        element<String>("id")
        element<String> ("raceDate")
    }

    override fun deserialize(decoder: Decoder): FormulaOneEvent {
        val jsonInput = decoder as? JsonDecoder ?: throw SerializationException("This serializer can be used only with JSON")

        val jsonObject = jsonInput.decodeJsonElement().jsonObject

        val name = jsonObject["raceName"]?.jsonPrimitive?.content ?: throw SerializationException("Invalid name")
        val id = jsonObject["raceId"]?.jsonPrimitive?.content ?: throw SerializationException("Invalid id")
        val raceDate = jsonObject["schedule"]?.jsonObject?.get("race")?.jsonObject?.get("date")?.jsonPrimitive?.content
        val raceTime = jsonObject["schedule"]?.jsonObject?.get("race")?.jsonObject?.get("time")?.jsonPrimitive?.content

        val dateTimeString = "$raceDate $raceTime"
        val dateTimeFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ssX")
        val raceDateTime = LocalDateTime.parse(dateTimeString, dateTimeFormatter)

        return FormulaOneEvent(name, id, raceDateTime)
    }

    override fun serialize(encoder: Encoder, value: FormulaOneEvent) {
        TODO("Not yet implemented")
    }

}