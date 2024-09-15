package ch.boosters.backend

import org.springframework.http.HttpEntity
import org.springframework.http.HttpHeaders
import org.springframework.http.MediaType
import org.springframework.util.LinkedMultiValueMap
import org.springframework.util.MultiValueMap
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController
import org.springframework.web.client.RestTemplate


@RestController
class LoginController {
    @GetMapping("/grantcode")
    fun grantCode(
        @RequestParam("code") code: String?,
        @RequestParam("scope") scope: String?,
        @RequestParam("authuser") authUser: String?,
        @RequestParam("prompt") prompt: String?
    ): String {
      return getOauthAccessTokenGoogle(code!!) ?: "Error"
    }


    private fun getOauthAccessTokenGoogle(code: String): String? {
        val restTemplate = RestTemplate()
        val httpHeaders: HttpHeaders = HttpHeaders()
        httpHeaders.setContentType(MediaType.APPLICATION_FORM_URLENCODED)

        val params: MultiValueMap<String, String> = LinkedMultiValueMap()
        params.add("code", code)
        params.add("redirect_uri", "http://localhost:8080/api/grantcode")
        params.add("client_id", "5100823542-pasq5mdgfm0uqu5q4n8rbss8r9k7pa12.apps.googleusercontent.com")
        params.add("client_secret", "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")
        params.add("scope", "https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.profile")
        params.add("scope", "https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email")
        params.add("scope", "openid")
        params.add("grant_type", "authorization_code")

        val requestEntity = HttpEntity(params, httpHeaders)

        val url = "https://oauth2.googleapis.com/token"
        val response = restTemplate.postForObject(url, requestEntity, String::class.java)
        return response
    }
}