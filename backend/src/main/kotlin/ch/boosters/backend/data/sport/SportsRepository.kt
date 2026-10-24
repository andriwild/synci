package ch.boosters.backend.data.sport

import arrow.core.Either
import arrow.core.raise.either
import ch.boosters.backend.data.configuration.JooqEitherDsl
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.backend.errorhandling.SynciError
import ch.boosters.data.tables.EventsTable.Companion.EVENTS_TABLE
import ch.boosters.data.tables.SportsTable.Companion.SPORTS_TABLE
import ch.boosters.data.tables.TeamsSportsTable.Companion.TEAMS_SPORTS_TABLE
import ch.boosters.data.tables.TeamsTable.Companion.TEAMS_TABLE
import ch.boosters.data.tables.pojos.EventsTable
import ch.boosters.data.tables.pojos.SportsTable
import ch.boosters.data.tables.pojos.TeamsTable
import org.jooq.DSLContext
import org.jooq.Record
import org.jooq.SelectConditionStep
import org.springframework.stereotype.Repository
import java.time.LocalDateTime
import java.util.*

@Repository
class SportsRepository(
    private val dsl: JooqEitherDsl
) {
    private val sports = SPORTS_TABLE

    /** Every row, including organisations and their groups. */
    fun allSports(): Either<SynciError, List<SportsTable>> =
        dsl { it.selectFrom(sports)
            .orderBy(SPORTS_TABLE.LABEL)
            .fetch().into(SportsTable::class.java) }

    /** The public tree: sports without an organisation. */
    fun publicSports(): Either<SynciError, List<SportsTable>> =
        dsl { it.selectFrom(sports)
            .where(sports.ORGANISATION_ID.isNull)
            .orderBy(SPORTS_TABLE.LABEL)
            .fetch().into(SportsTable::class.java) }

    fun sportById(id: UUID): SynciEither<SportsTable?> =
        dsl { it.selectFrom(sports).where(sports.ID.eq(id)).fetchOneInto(SportsTable::class.java) }

    fun sportsOfOrganisations(organisationIds: Collection<UUID>): SynciEither<List<SportsTable>> =
        if (organisationIds.isEmpty()) either { emptyList() }
        else dsl {
            it.selectFrom(sports)
                .where(sports.ORGANISATION_ID.`in`(organisationIds))
                .orderBy(sports.LABEL)
                .fetch().into(SportsTable::class.java)
        }

    fun sportIdByName(name: String): SynciEither<UUID?> = either {
        dsl {
            it
                .selectFrom(sports)
                .where(sports.NAME.eq(name))
                .fetchOne()
                ?.get(sports.ID)
        }.bind()
    }

    fun eventsBySports(sportIds: List<UUID>, limit: Int, offset: Int, dateTime: LocalDateTime): Either<SynciError, List<EventsTable>> =
        dsl {
            it.selectFrom(EVENTS_TABLE)
                .where(EVENTS_TABLE.SPORT_ID.`in`(sportIds))
                .and(EVENTS_TABLE.STARTS_ON.greaterOrEqual(dateTime))
                .orderBy(EVENTS_TABLE.STARTS_ON)
                .limit(offset, limit)
                .fetch()
                .into(EventsTable::class.java)
        }

    fun sportIdsWithTeams(): SynciEither<Set<UUID>> =
        dsl {
            it.selectDistinct(TEAMS_SPORTS_TABLE.SPORT_ID).from(TEAMS_SPORTS_TABLE)
                .fetch(TEAMS_SPORTS_TABLE.SPORT_ID)
                .filterNotNull()
                .toSet()
        }

    fun teamsBySportsCount(sportIds: List<UUID>, searchTerm: String? = null): Either<SynciError, Int> =
        dsl {
            teamsBySport(it, sportIds, searchTerm)
                .count()
        }

    fun eventsBySportsCount(sportIds: List<UUID>, dateTime: LocalDateTime): Either<SynciError, Int> =
        dsl {
            it.selectFrom(EVENTS_TABLE)
                .where(EVENTS_TABLE.SPORT_ID.`in`(sportIds))
                .and(EVENTS_TABLE.STARTS_ON.greaterOrEqual(dateTime))
                .count()
        }

    fun getTeamsBySportIds(sportIds: List<UUID>, limit: Int, offset: Int, searchTerm: String? = null): Either<SynciError, List<TeamsTable>> =
        dsl {
            teamsBySport(it, sportIds, searchTerm)
                .orderBy(TEAMS_TABLE.NAME)
                .limit(offset, limit)
                .fetchInto(TeamsTable::class.java)
        }

    private fun teamsBySport(
        dsl: DSLContext,
        sportIds: List<UUID>,
        searchTerm: String? = null
    ): SelectConditionStep<Record> {
        val query = dsl.selectDistinct(TEAMS_TABLE.asterisk())
            .from(TEAMS_TABLE)
            .leftJoin(TEAMS_SPORTS_TABLE)
            .on(
                TEAMS_TABLE.ID.eq(TEAMS_SPORTS_TABLE.TEAM_ID).and(TEAMS_TABLE.SOURCE_ID.eq(TEAMS_SPORTS_TABLE.SOURCE_TEAM_ID))
            )
            .where(TEAMS_SPORTS_TABLE.SPORT_ID.`in`(sportIds))
        return if (!searchTerm.isNullOrBlank()) {
            query.and(TEAMS_TABLE.NAME.containsIgnoreCase(searchTerm))
        } else {
            query
        }
    }
}