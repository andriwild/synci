package ch.boosters.backend.config

import EventSyncJob
import org.quartz.*
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.scheduling.quartz.JobDetailFactoryBean
import org.springframework.scheduling.quartz.SimpleTriggerFactoryBean
import java.util.*

@Configuration
class QuartzConfig {

    @Bean
    fun dailyJobDetail(): JobDetailFactoryBean {
        val jobDetail = JobDetailFactoryBean()
        jobDetail.setJobClass(EventSyncJob::class.java)
        jobDetail.setDescription("Invoke Service Method Daily")
        jobDetail.setDurability(true)
        return jobDetail
    }

    @Bean
    fun dailyTrigger(jobDetail: JobDetail): SimpleTriggerFactoryBean {
        val trigger = SimpleTriggerFactoryBean()
        trigger.setJobDetail(jobDetail)
        trigger.setRepeatInterval(24 * 60 * 60 * 1000L) // daily trigger (24 h)
//        trigger.setRepeatInterval(5 * 60 * 1000L) // each 5 min
        trigger.setStartTime(Date(System.currentTimeMillis() + 3000)) // start after 3 sec
        trigger.setRepeatCount(SimpleTrigger.REPEAT_INDEFINITELY)
        return trigger
    }
}
