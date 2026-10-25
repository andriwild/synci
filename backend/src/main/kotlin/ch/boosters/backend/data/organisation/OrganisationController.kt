package ch.boosters.backend.data.organisation

import arrow.core.raise.either
import ch.boosters.backend.auth.CurrentUserResolver
import ch.boosters.backend.data.organisation.model.AnswerDto
import ch.boosters.backend.data.organisation.model.EventResponseSummary
import ch.boosters.backend.data.organisation.model.GroupDto
import ch.boosters.backend.data.organisation.model.MemberView
import ch.boosters.backend.data.organisation.model.MyOrganisation
import ch.boosters.backend.data.organisation.model.OrganisationDto
import ch.boosters.backend.data.organisation.model.OrganisationEventDto
import ch.boosters.backend.data.organisation.model.OrganisationSummary
import ch.boosters.backend.data.organisation.model.OrganisationView
import ch.boosters.backend.data.organisation.model.RoleUpdateDto
import ch.boosters.backend.data.sport.model.PagedResult
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.backend.data.sport.model.Sport
import ch.boosters.data.tables.pojos.EventsTable
import ch.boosters.data.tables.pojos.OrganisationMembersTable
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.Authentication
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.PutMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController
import java.util.UUID

@RestController
@RequestMapping("/organisations")
@PreAuthorize("isAuthenticated()")
class OrganisationController(
    private val organisationService: OrganisationService,
    private val organisationEventService: OrganisationEventService,
    private val responseService: OrganisationEventResponseService,
    private val currentUserResolver: CurrentUserResolver
) {

    // ---- organisations ----

    @GetMapping("")
    fun myOrganisations(authentication: Authentication): SynciEither<List<MyOrganisation>> = either {
        val userId = currentUserResolver.getUserId(authentication).bind()
        organisationService.myOrganisations(userId).bind()
    }

    @PostMapping("")
    fun create(@RequestBody organisation: OrganisationDto, authentication: Authentication): SynciEither<OrganisationView> =
        either {
            val userId = currentUserResolver.getUserId(authentication).bind()
            organisationService.create(organisation, userId).bind()
        }

    @GetMapping("/discover")
    fun discover(
        @RequestParam(required = false) searchTerm: String?,
        @RequestParam(defaultValue = "0") page: Int,
        @RequestParam(defaultValue = "20") pageSize: Int,
        authentication: Authentication
    ): SynciEither<PagedResult<OrganisationSummary>> = either {
        val userId = currentUserResolver.getUserId(authentication).bind()
        organisationService.discover(userId, searchTerm, page, pageSize).bind()
    }

    @GetMapping("/{id}")
    fun getById(@PathVariable id: UUID, authentication: Authentication): SynciEither<OrganisationView> = either {
        val userId = currentUserResolver.getUserId(authentication).bind()
        organisationService.getById(id, userId).bind()
    }

    @PutMapping("/{id}")
    fun update(
        @PathVariable id: UUID,
        @RequestBody organisation: OrganisationDto,
        authentication: Authentication
    ): SynciEither<OrganisationView> = either {
        val userId = currentUserResolver.getUserId(authentication).bind()
        organisationService.update(id, organisation, userId).bind()
    }

    @DeleteMapping("/{id}")
    fun delete(@PathVariable id: UUID, authentication: Authentication): SynciEither<Int> = either {
        val userId = currentUserResolver.getUserId(authentication).bind()
        organisationService.delete(id, userId).bind()
    }

    // ---- membership ----

    @PostMapping("/{id}/join-requests")
    fun requestJoin(@PathVariable id: UUID, authentication: Authentication): SynciEither<OrganisationMembersTable> = either {
        val userId = currentUserResolver.getUserId(authentication).bind()
        organisationService.requestJoin(id, userId).bind()
    }

    @DeleteMapping("/{id}/members/me")
    fun leave(@PathVariable id: UUID, authentication: Authentication): SynciEither<Int> = either {
        val userId = currentUserResolver.getUserId(authentication).bind()
        organisationService.leave(id, userId).bind()
    }

    @GetMapping("/{id}/members")
    fun members(@PathVariable id: UUID, authentication: Authentication): SynciEither<List<MemberView>> = either {
        val userId = currentUserResolver.getUserId(authentication).bind()
        organisationService.members(id, userId).bind()
    }

    @PutMapping("/{id}/members/{memberId}/approve")
    fun approve(
        @PathVariable id: UUID,
        @PathVariable memberId: UUID,
        authentication: Authentication
    ): SynciEither<MemberView> = either {
        val userId = currentUserResolver.getUserId(authentication).bind()
        organisationService.approve(id, memberId, userId).bind()
    }

    @PutMapping("/{id}/members/{memberId}/role")
    fun changeRole(
        @PathVariable id: UUID,
        @PathVariable memberId: UUID,
        @RequestBody update: RoleUpdateDto,
        authentication: Authentication
    ): SynciEither<MemberView> = either {
        val userId = currentUserResolver.getUserId(authentication).bind()
        organisationService.changeRole(id, memberId, update, userId).bind()
    }

    @DeleteMapping("/{id}/members/{memberId}")
    fun removeMember(
        @PathVariable id: UUID,
        @PathVariable memberId: UUID,
        authentication: Authentication
    ): SynciEither<Int> = either {
        val userId = currentUserResolver.getUserId(authentication).bind()
        organisationService.removeMember(id, memberId, userId).bind()
    }

    // ---- groups ----

    @PostMapping("/{id}/groups")
    fun createGroup(
        @PathVariable id: UUID,
        @RequestBody group: GroupDto,
        authentication: Authentication
    ): SynciEither<Sport> = either {
        val userId = currentUserResolver.getUserId(authentication).bind()
        organisationService.createGroup(id, group, userId).bind()
    }

    @PutMapping("/{id}/groups/{groupId}")
    fun updateGroup(
        @PathVariable id: UUID,
        @PathVariable groupId: UUID,
        @RequestBody group: GroupDto,
        authentication: Authentication
    ): SynciEither<Sport> = either {
        val userId = currentUserResolver.getUserId(authentication).bind()
        organisationService.updateGroup(id, groupId, group, userId).bind()
    }

    @DeleteMapping("/{id}/groups/{groupId}")
    fun deleteGroup(
        @PathVariable id: UUID,
        @PathVariable groupId: UUID,
        authentication: Authentication
    ): SynciEither<Int> = either {
        val userId = currentUserResolver.getUserId(authentication).bind()
        organisationService.deleteGroup(id, groupId, userId).bind()
    }

    // ---- events ----

    @PostMapping("/{id}/events")
    fun createEvent(
        @PathVariable id: UUID,
        @RequestBody event: OrganisationEventDto,
        authentication: Authentication
    ): SynciEither<EventsTable> = either {
        val userId = currentUserResolver.getUserId(authentication).bind()
        organisationEventService.create(id, event, userId).bind()
    }

    @PutMapping("/{id}/events/{eventId}")
    fun updateEvent(
        @PathVariable id: UUID,
        @PathVariable eventId: String,
        @RequestBody event: OrganisationEventDto,
        authentication: Authentication
    ): SynciEither<EventsTable> = either {
        val userId = currentUserResolver.getUserId(authentication).bind()
        organisationEventService.update(id, eventId, event, userId).bind()
    }

    @DeleteMapping("/{id}/events/{eventId}")
    fun deleteEvent(
        @PathVariable id: UUID,
        @PathVariable eventId: String,
        authentication: Authentication
    ): SynciEither<Int> = either {
        val userId = currentUserResolver.getUserId(authentication).bind()
        organisationEventService.delete(id, eventId, userId).bind()
    }

    // ---- answers ----

    @GetMapping("/{id}/responses")
    fun responses(@PathVariable id: UUID, authentication: Authentication): SynciEither<List<EventResponseSummary>> =
        either {
            val userId = currentUserResolver.getUserId(authentication).bind()
            responseService.summaries(id, userId).bind()
        }

    @PutMapping("/{id}/events/{eventId}/response")
    fun answer(
        @PathVariable id: UUID,
        @PathVariable eventId: String,
        @RequestBody answer: AnswerDto,
        authentication: Authentication
    ): SynciEither<EventResponseSummary> = either {
        val userId = currentUserResolver.getUserId(authentication).bind()
        responseService.answer(id, eventId, userId, answer.answer).bind()
    }
}
