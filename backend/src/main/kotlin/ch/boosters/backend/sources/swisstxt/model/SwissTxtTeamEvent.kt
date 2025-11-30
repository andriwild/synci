package ch.boosters.backend.sources.swisstxt.model

import ch.boosters.backend.data.event.model.TeamEvent
import ch.boosters.backend.data.team.Gender
import kotlinx.serialization.KSerializer
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


object SwissTxtTeamEventSerializer : KSerializer<TeamEvent> {
    override val descriptor: SerialDescriptor = buildClassSerialDescriptor("TeamEvent") {
        element<String>("name")
        element<Int>("id")
        element<String>("startsOn")
        element<String>("endsOn")
    }

    override fun deserialize(decoder: Decoder): TeamEvent {
        val jsonInput =
            decoder as? JsonDecoder ?: throw SerializationException("This serializer can be used only with JSON")

        val jsonObject = jsonInput.decodeJsonElement().jsonObject
        val homeName   = jsonObject["competitor1"]?.jsonObject?.get("name")?.jsonPrimitive?.content ?: ""
        val homeId     = jsonObject["competitor1"]?.jsonObject?.get("id")  ?.jsonPrimitive?.content ?: ""
        val awayName   = jsonObject["competitor2"]?.jsonObject?.get("name")?.jsonPrimitive?.content ?: ""
        val awayId     = jsonObject["competitor2"]?.jsonObject?.get("id")  ?.jsonPrimitive?.content ?: ""
        val genderStr  = jsonObject["gender"]?.jsonPrimitive?.content ?: throw SerializationException("Invalid gender info")
        val id         = jsonObject["id"]?.jsonPrimitive?.content ?: throw SerializationException("Invalid id")

        val utcTime = jsonObject["dateTimeInfo"]?.jsonObject?.get("fullDateTime")?.jsonPrimitive?.content
            ?: throw SerializationException("Missing utcTime")

        val formatter = DateTimeFormatter.ISO_DATE_TIME
        val startsOn  = LocalDateTime.parse(utcTime, formatter)
        val endsOn    = startsOn.plusHours(2)

        return TeamEvent(id, startsOn, endsOn, homeId, homeName, awayId, awayName, Gender.fromString(genderStr))
    }

    override fun serialize(encoder: Encoder, value: TeamEvent) {
        // Implement if needed
        throw NotImplementedError("Serialization is not implemented")
    }
}