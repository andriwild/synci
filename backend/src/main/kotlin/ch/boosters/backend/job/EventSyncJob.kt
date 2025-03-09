import arrow.core.Either
import ch.boosters.backend.data.event.EventService
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
    lateinit var swissTxtService: SwissTxtService

    override fun execute(context: JobExecutionContext) {
        val updates = listOf(
            swissSkiService.update(),
            swissTxtService.update()
        )
        updates.map {
            when (it) {
                is Either.Left -> println("Something went wrong when inserting races: ${it.value.message}")
                is Either.Right -> println("Successfully inserted data")
            }
        }
    }
}