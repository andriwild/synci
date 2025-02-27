package ch.boosters.backend.data.sport

import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/swissski")
class SportController (
    private val sportsService: SportService
) {

    @GetMapping("/list")
    fun getSubcategoriesOfCategory(): List<Sport> {
        return sportsService.getSubcategoriesOfCategory()
    }
}
