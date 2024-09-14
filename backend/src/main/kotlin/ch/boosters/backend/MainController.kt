package ch.boosters.backend

import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController

@RestController
class ArticleController() {

  @GetMapping("/")
  fun greeting(@RequestParam name: String): String  {
    return "hello $name"
  }
}