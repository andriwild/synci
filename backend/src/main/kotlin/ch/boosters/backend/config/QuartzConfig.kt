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
        jobDetail.setJobClass(EventSyncJob::class.java) // Die Klasse, die den Job implementiert
        jobDetail.setDescription("Invoke Service Method Daily")
        jobDetail.setDurability(true)
        return jobDetail
    }

    @Bean
    fun dailyTrigger(jobDetail: JobDetail): SimpleTriggerFactoryBean {
        val trigger = SimpleTriggerFactoryBean()
        trigger.setJobDetail(jobDetail)
        trigger.setRepeatInterval(24 * 60 * 60 * 1000L) // Einmal täglich (24 Stunden)
//        trigger.setRepeatInterval(5 * 60 * 1000L) // Alle 5 Minuten
        trigger.setStartTime(Date(System.currentTimeMillis() + 3000)) // Start nach 3 Sekunden
        trigger.setRepeatCount(SimpleTrigger.REPEAT_INDEFINITELY)
        return trigger
    }
}
