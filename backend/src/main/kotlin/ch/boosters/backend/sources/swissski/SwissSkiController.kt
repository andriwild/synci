package ch.boosters.backend.sources.swissski

import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/swissski")
class SwissSkiController(
    private val swissSkiService: SwissSkiService
) {

    @GetMapping("/categories/{category}")
    fun getSubcategoriesOfCategory(@PathVariable category: String): List<String> {
        return swissSkiService.getSubcategoriesOfCategory(category)
    }
}
