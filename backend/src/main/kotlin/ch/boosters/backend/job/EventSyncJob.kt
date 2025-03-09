import ch.boosters.backend.data.event.EventService
import ch.boosters.backend.sources.fotmob.FotMobService
import ch.boosters.backend.sources.swissski.SwissSkiService
import ch.boosters.backend.sources.swisstxt.SwissTxtService
import org.quartz.Job
import org.quartz.JobExecutionContext
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Component

@Component
class EventSyncJob : Job {

    @Autowired
    lateinit var fotMobService: FotMobService
    @Autowired
    lateinit var swissSkiService: SwissSkiService
    @Autowired
    lateinit var eventService: EventService
    @Autowired
    lateinit var swissTxtService: SwissTxtService

    override fun execute(context: JobExecutionContext) {
        val result = eventService.clearTables()
        if (result) {
            // TODO: #13 split up update procedures
            fotMobService.updateLeagues()
            swissSkiService.updateRaces()
            swissTxtService.update()
        }
    }
}