@RestController
@RequestMapping("/api/article")
class ArticleController(private val repository: ArticleRepository) {

  @GetMapping("/")
  fun findAll() = repository.findAllByOrderByAddedAtDesc()

  @GetMapping("/{slug}")
  fun findOne(@PathVariable slug: String) =
      repository.findBySlug(slug) ?: throw ResponseStatusException(HttpStatus.NOT_FOUND, "This article does not exist")

}