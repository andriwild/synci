package ch.boosters.backend.data.organisation

import ch.boosters.backend.data.organisation.model.AnswerDto
import ch.boosters.backend.data.organisation.model.EventInvitation
import ch.boosters.backend.errorhandling.SynciEither
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PutMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import java.util.UUID

/** Answer links in the calendar feeds work without login: like the feed itself, the sync config id stands for its owner. */
@RestController
@RequestMapping("/calendars/{configId}/events/{eventId}/response")
class EventInvitationController(private val responseService: OrganisationEventResponseService) {

    @GetMapping
    fun invitation(@PathVariable configId: UUID, @PathVariable eventId: String): SynciEither<EventInvitation> =
        responseService.invitation(configId, eventId)

    @PutMapping
    fun answer(
        @PathVariable configId: UUID,
        @PathVariable eventId: String,
        @RequestBody answer: AnswerDto
    ): SynciEither<EventInvitation> =
        responseService.answerViaLink(configId, eventId, answer.answer)
}
