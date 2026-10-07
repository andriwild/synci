package ch.boosters.backend.config

import EventSyncJob
import org.quartz.*
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.scheduling.quartz.JobDetailFactoryBean
import org.springframework.scheduling.quartz.SimpleTriggerFactoryBean
import java.time.Duration
import java.util.*

val SYNC_INTERVAL: Duration = Duration.ofHours(12)

@Configuration
class QuartzConfig {

    @Bean
    fun dailyJobDetail(): JobDetailFactoryBean {
        val jobDetail = JobDetailFactoryBean()
        jobDetail.setJobClass(EventSyncJob::class.java)
        jobDetail.setDescription("Invoke Service Method every 12 hours")
        jobDetail.setDurability(true)
        return jobDetail
    }

    @Bean
    fun dailyTrigger(jobDetail: JobDetail): SimpleTriggerFactoryBean {
        val trigger = SimpleTriggerFactoryBean()
        trigger.setJobDetail(jobDetail)
        trigger.setRepeatInterval(SYNC_INTERVAL.toMillis()) // twice a day (12 h)
//        trigger.setRepeatInterval(5 * 60 * 1000L) // each 5 min
        trigger.setStartTime(Date(System.currentTimeMillis() + 3000)) // start after 3 sec
        trigger.setRepeatCount(SimpleTrigger.REPEAT_INDEFINITELY)
        return trigger
    }
}
