package ch.boosters.backend.data.user

import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/user")
class UserController {

    @GetMapping("/me")
    fun me(): String {
        return "Elias"
    }
}