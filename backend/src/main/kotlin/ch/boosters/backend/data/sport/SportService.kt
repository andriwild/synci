package ch.boosters.backend.data.sport

import arrow.core.Either
import arrow.core.raise.either
import ch.boosters.backend.errorhandling.SynciError
import ch.boosters.data.tables.pojos.SportsTable
import org.springframework.stereotype.Service

@Service
class SportService(
    private val sportRepository: SportRepository
) {
    fun findSports(): Either<SynciError, List<Sport>> = either {
        val sports: List<SportsTable> = sportRepository.allSports().bind()
        sports.groupByRootSports()
    }
}
