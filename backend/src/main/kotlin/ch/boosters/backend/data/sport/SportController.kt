package ch.boosters.backend.data.sport

import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/sports")
class SportController (
    private val sportsService: SportService
) {

    @GetMapping("/")
    fun getAllSports(): List<Sport> {
        return sportsService.getSports()
    }
}
