import ch.boosters.backend.data.event.EventService
import ch.boosters.backend.sources.fotmob.FotMobService
import ch.boosters.backend.sources.swissski.SwissSkiService
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

    override fun execute(context: JobExecutionContext) {
        val result = eventService.clearTables()
        if (result) {
            fotMobService.updateLeagues()
            swissSkiService.updateRaces()
        }
    }
}
