package ch.boosters.backend.data.syncConfig

import arrow.core.Either
import arrow.core.flatMap
import arrow.core.raise.either
import arrow.core.raise.ensure
import ch.boosters.backend.data.event.EventRepository
import ch.boosters.backend.data.organisation.OrganisationAccess
import ch.boosters.backend.data.sport.SportsRepository
import ch.boosters.backend.data.sport.business.rootSportOf
import ch.boosters.backend.data.syncConfig.model.MatchupDto
import ch.boosters.backend.data.syncConfig.model.SyncConfigDto
import ch.boosters.backend.data.syncConfig.syncConfigEvents.SyncConfigEventsRepository
import ch.boosters.backend.data.syncConfig.syncConfigMatchups.MATCHUP_LIMIT
import ch.boosters.backend.data.syncConfig.syncConfigMatchups.SyncConfigMatchupRepository
import ch.boosters.backend.data.syncConfig.syncConfigMatchups.normalizeMatchups
import ch.boosters.backend.data.syncConfig.syncConfigSports.SyncConfigSportsRepository
import ch.boosters.backend.data.syncConfig.syncConfigTeam.SyncConfigTeamRepository
import ch.boosters.backend.data.team.TeamResponse
import ch.boosters.backend.errorhandling.ElementNotFound
import ch.boosters.backend.errorhandling.InvalidRequest
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.backend.errorhandling.SynciError
import ch.boosters.data.tables.pojos.SyncConfigsTable
import org.springframework.stereotype.Service
import java.util.UUID

@Service
class SyncConfigService(
    private val syncConfigRepository: SyncConfigRepository,
    private val syncConfigTeamRepository: SyncConfigTeamRepository,
    private val syncConfigSportsRepository: SyncConfigSportsRepository,
    private val syncConfigEventsRepository: SyncConfigEventsRepository,
    private val syncConfigMatchupRepository: SyncConfigMatchupRepository,
    private val sportsRepository: SportsRepository,
    private val eventRepository: EventRepository,
    private val organisationAccess: OrganisationAccess
) {

    fun createSyncConfig(syncConfig: SyncConfigDto, userId: UUID): SynciEither<SyncConfig> = either {
        val cleanedConfig = removeDuplicates(syncConfig)
        validateOrganisationAccess(cleanedConfig, userId).bind()
        val matchups = validMatchups(cleanedConfig.matchups).bind().orEmpty()
        val id = syncConfigRepository.createSyncConfig(cleanedConfig, userId).bind()
        syncConfigTeamRepository.addTeams(id, cleanedConfig.teams).bind()
        syncConfigSportsRepository.addSports(id, cleanedConfig.sports).bind()
        syncConfigEventsRepository.addEvents(id, cleanedConfig.events).bind()
        syncConfigMatchupRepository.replaceMatchups(id, matchups).bind()
        syncConfigById(id, userId).bind()
    }

    fun allSyncConfigsForUser(userId: UUID): SynciEither<List<SyncConfig>> = either {
        val configs = syncConfigRepository.findAllSyncConfigsByUser(userId).bind()
        configs.map { syncConfigById(it.id, userId) }.bindAll()
    }

    fun syncConfigById(id: UUID, userId: UUID): SynciEither<SyncConfig> = either {
        val syncConfig = syncConfigBelongsToUser(id, userId).bind()
        val sportsOfConfig = syncConfigSportsRepository.getSportsIdBySyncConfigId(id).bind()
        val teamsOfConfig = syncConfigTeamRepository.getTeamBySyncConfigId(id).bind()
        val eventIdsInConfig = syncConfigEventsRepository.getEventsIdsBySyncConfigId(id).bind()
        val matchupsOfConfig = syncConfigMatchupRepository.getMatchups(id).bind()

        val allSports = sportsRepository.allSports().bind()
        val teamSportMap = syncConfigTeamRepository.getTeamSportPairsBySyncConfigId(id).bind()
            .groupBy({ it.first }, { it.second })

        fun rootLabel(sportId: UUID?): String? =
            allSports.rootSportOf(sportId)?.let { it.label ?: it.name }

        SyncConfig(
            id = id,
            name = syncConfig.name,
            teams = teamsOfConfig.map { WithRootSport(TeamResponse.of(it), rootLabel(teamSportMap[it.id]?.firstOrNull())) },
            sports = sportsOfConfig.map { WithRootSport(it, rootLabel(it.id)) },
            events = eventRepository.withTeams(eventIdsInConfig).bind().map { WithRootSport(it, rootLabel(it.event.sportId)) },
            matchups = matchupsOfConfig.map {
                WithRootSport(MatchupResponse(it.sourceId, TeamResponse.of(it.teamA), TeamResponse.of(it.teamB)), rootLabel(it.sportIds.firstOrNull()))
            },
            matchupLimit = MATCHUP_LIMIT,
        )
    }

    fun updateSyncConfig(id: UUID, syncConfig: SyncConfigDto, userId: UUID): SynciEither<SyncConfig> = either {
        // check ownership before writing anything; previously only the final read was checked
        syncConfigBelongsToUser(id, userId).bind()
        val cleanedConfig = removeDuplicates(syncConfig)
        validateOrganisationAccess(cleanedConfig, userId).bind()
        val matchups = validMatchups(cleanedConfig.matchups).bind()
        syncConfigRepository.updateSyncConfig(id, cleanedConfig).bind()
        syncConfigTeamRepository.updateTeams(id, cleanedConfig.teams).bind()
        syncConfigEventsRepository.updateEvents(id, cleanedConfig.events).bind()
        syncConfigSportsRepository.updateSports(id, cleanedConfig.sports).bind()
        matchups?.let { syncConfigMatchupRepository.replaceMatchups(id, it).bind() }
        syncConfigById(id, userId).bind()
    }

    /** Top Events without repeats and with existing teams; null when the client sent none. */
    private fun validMatchups(matchups: List<MatchupDto>?): SynciEither<List<MatchupDto>?> = either {
        if (matchups == null) return@either null
        val normalized = normalizeMatchups(matchups).bind()
        val unknown = syncConfigMatchupRepository.unknownTeams(normalized).bind()
        ensure(unknown.isEmpty()) { InvalidRequest("Unbekannte Teams: ${unknown.joinToString()}") }
        normalized
    }

    private fun removeDuplicates(syncConfig: SyncConfigDto): SyncConfigDto {
        val events = syncConfig.events.distinctBy { it.id }
        val teams = syncConfig.teams.distinctBy { it.id }
        val sports = syncConfig.sports.distinct()
        return syncConfig.copy(events = events, teams = teams, sports = sports)
    }

    fun deleteSyncConfig(id: UUID, userId: UUID): SynciEither<Int> =
        syncConfigBelongsToUser(id, userId).flatMap { syncConfig ->
            syncConfigRepository.deleteById(syncConfig.id)
        }

    /** Sports and events that belong to an organisation may only be subscribed by its active members. */
    private fun validateOrganisationAccess(syncConfig: SyncConfigDto, userId: UUID): SynciEither<Unit> = either {
        val organisationOfSport = sportsRepository.allSports().bind()
            .filter { it.organisationId != null }
            .associate { it.id to it.organisationId!! }

        val organisationIds = mutableSetOf<UUID>()
        syncConfig.sports.forEach { sportId -> organisationOfSport[sportId]?.let { organisationIds.add(it) } }
        syncConfig.events.forEach { eventDto ->
            val event = eventRepository.findEvent(eventDto.id, eventDto.sourceId).bind()
            if (event != null) organisationOfSport[event.sportId]?.let { organisationIds.add(it) }
        }
        organisationIds.forEach { organisationAccess.requireActiveMember(it, userId).bind() }
    }

    private fun syncConfigBelongsToUser(syncConfigId: UUID, userId: UUID): Either<SynciError, SyncConfigsTable> =
        either {
            val configs = syncConfigRepository.findAllSyncConfigsByUser(userId).bind()
            val syncConfig = configs.find { it.id.equals(syncConfigId) }
            ensure(syncConfig != null) {
                ElementNotFound("Could not find sync config with id $syncConfigId, for user $userId")
            }
            syncConfig
        }
}
