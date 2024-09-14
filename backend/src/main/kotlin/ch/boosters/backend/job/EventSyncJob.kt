import ch.boosters.backend.fotmob.FotMobService
import org.quartz.Job
import org.quartz.JobExecutionContext
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Component
import java.time.LocalDateTime

@Component
class EventSyncJob : Job {

    @Autowired
    lateinit var fotMobService: FotMobService

    override fun execute(context: JobExecutionContext) {
        //TODO Query repository for all leagues

        //current date and time
        val currentDateTime = LocalDateTime.now()
        println("Fetching all leagues from FotMob at $currentDateTime")

        fotMobService.fetchLeagueOverview("69")
    }
}