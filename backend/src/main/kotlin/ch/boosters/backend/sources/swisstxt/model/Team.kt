package ch.boosters.backend.sources.swisstxt.model

import kotlinx.serialization.*
import kotlinx.serialization.descriptors.SerialDescriptor
import kotlinx.serialization.descriptors.buildClassSerialDescriptor
import kotlinx.serialization.descriptors.element
import kotlinx.serialization.encoding.Decoder
import kotlinx.serialization.encoding.Encoder
import kotlinx.serialization.json.JsonDecoder
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive

@Serializable(with = SwissTxtTeamSerializer::class)
data class Team(val name: String, val id: Int)

object SwissTxtTeamSerializer : KSerializer<Team> {
    override val descriptor: SerialDescriptor = buildClassSerialDescriptor("Event") {
        element<String>("name")
        element<Int>("id")
    }

    override fun deserialize(decoder: Decoder): Team {
        val jsonInput = decoder as? JsonDecoder ?: throw SerializationException("This serializer can be used only with JSON")
        val jsonObject = jsonInput.decodeJsonElement().jsonObject
        val name = jsonObject["competitor1"]?.jsonObject?.get("name")?.jsonPrimitive?.content ?: ""
        val id = jsonObject["competitor1"]?.jsonObject?.get("id")?.jsonPrimitive?.content ?: ""

        return Team(name, id.toInt())
    }

    override fun serialize(encoder: Encoder, value: Team) {
        throw NotImplementedError("Serialization is not implemented")
    }
}