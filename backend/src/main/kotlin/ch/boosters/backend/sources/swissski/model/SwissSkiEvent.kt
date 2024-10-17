package ch.boosters.backend.sources.swissski.model

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

@Serializable(with = SwissSkiEventSerializer::class)
data class SwissSkiEvent(
    val place: String,
    val id: String,
    @Contextual val raceDate: LocalDateTime,
    val nationCode: String,
    val gender: String,
    val disciplineCode: String,
    val catCode: String,
)

object SwissSkiEventSerializer: KSerializer<SwissSkiEvent> {
    override val descriptor: SerialDescriptor = buildClassSerialDescriptor("Event") {
        element<String>("place")
        element<String>("id")
        element<String> ("raceDate")
        element<String> ("nationcode")
        element<String> ("gender")
        element<String> ("disciplinecode")
        element<String> ("catcode")
    }

    override fun deserialize(decoder: Decoder): SwissSkiEvent {
        val jsonInput = decoder as? JsonDecoder ?: throw SerializationException("This serializer can be used only with JSON")

        val jsonObject = jsonInput.decodeJsonElement().jsonObject

        val place = jsonObject["place"]?.jsonPrimitive?.content ?: ""
        val id = jsonObject["id"]?.jsonPrimitive?.content ?: throw SerializationException("Invalid id")
        val raceDate = jsonObject["racedate"]?.jsonPrimitive?.content ?: throw SerializationException("Missing utcTime")
        val nationCode = jsonObject["nationcode"]?.jsonPrimitive?.content ?: ""
        val gender = jsonObject["gender"]?.jsonPrimitive?.content ?: ""
        val disciplineCode = jsonObject["disciplinecode"]?.jsonPrimitive?.content ?: ""
        val catCode = jsonObject["catcode"]?.jsonPrimitive?.content ?: ""

        val formatter = DateTimeFormatter.ISO_DATE
        val localDate = LocalDate.parse(raceDate, formatter)
        val localDateTime = localDate.atStartOfDay()

        return SwissSkiEvent(place, id, localDateTime, nationCode, gender, disciplineCode, catCode)
    }

    override fun serialize(encoder: Encoder, value: SwissSkiEvent) {
        TODO("Not yet implemented")
    }

}
