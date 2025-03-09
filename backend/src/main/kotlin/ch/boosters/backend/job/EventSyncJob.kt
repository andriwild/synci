import arrow.core.Either
import ch.boosters.backend.data.event.EventService
import ch.boosters.backend.errorhandling.SynciError
import ch.boosters.backend.sources.swissski.SwissSkiService
import ch.boosters.backend.sources.swisstxt.SwissTxtService
import org.quartz.Job
import org.quartz.JobExecutionContext
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Component

@Component
class EventSyncJob : Job {

    @Autowired
    lateinit var swissSkiService: SwissSkiService
    @Autowired
    lateinit var eventService: EventService
    @Autowired
    lateinit var swissTxtService: SwissTxtService

    override fun execute(context: JobExecutionContext) {
        val result = eventService.clearTables().map {
            // TODO: use a result here for proper error handling
            swissSkiService.updateRaces()
            swissTxtService.update()
        }
        when (result) {
            is Either.Left -> println("Something went wrong when inserting races: ${result.value.message}")
            is Either.Right -> println("Successfully inserted races")
        }
    }
}