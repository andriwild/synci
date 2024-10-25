package ch.boosters.backend.sources.fotmob

import org.springframework.stereotype.Service
import org.springframework.web.reactive.function.client.ExchangeStrategies
import org.springframework.web.reactive.function.client.WebClient
import reactor.core.publisher.Mono
import java.time.LocalDateTime

@Service
class FotMobService(
    private val webClientBuilder: WebClient.Builder,
    private val serializer: LeagueSerializer,
    private val fotMobRepository: FotMobRepository,
    private val fotMobConfig: FotMobConfig,
) {
    fun updateLeagues() {
        val leagues = fotMobConfig.leagues

        println("Fetching ${leagues.size} leagues from FotMob at ${LocalDateTime.now()}")
        leagues.forEachIndexed { index, league ->
            val progress = (index + 1) * (100.0 / leagues.size)
            print("\r ${"=".repeat(progress.toInt())}> ${progress.toInt()}%")
            fetchLeagueOverview(league.id).block()
        }
        println("\nDone!")
    }

    fun fetchLeagueOverview(leagueId: String): Mono<IntArray> {
        val baseUrl = fotMobConfig.url
        val url = "$baseUrl/leagues?id=$leagueId&tab=overview&type=league"
        val exchangeStrategies = ExchangeStrategies.builder()
            .codecs { configurer ->
                configurer.defaultCodecs().maxInMemorySize(10 * 1024 * 1024) // 10 MB
            }
            .build()

        val response = leaguesResponse(exchangeStrategies, url)
        return response
            .map(serializer::parseResponse)
            .map{ (events, teams) ->
                val resTeams  = fotMobRepository.storeTeams(teams)
                val resEvents = fotMobRepository.storeEvents(events)
                resTeams
            }
    }

    private fun leaguesResponse(exchangeStrategies: ExchangeStrategies, url: String): Mono<String> {
        return try {
            webClientBuilder
                .exchangeStrategies(exchangeStrategies)
                .build()
                .get()
                .uri(url)
                .retrieve()
                .bodyToMono(String::class.java)
        } catch (e: Exception) {
            println("Error fetching league overview: $e")
            Mono.empty()
        }
    }
}