package ch.boosters.backend.errorhandling

import arrow.core.Either
import org.springframework.core.MethodParameter
import org.springframework.http.MediaType
import org.springframework.http.ResponseEntity
import org.springframework.http.converter.HttpMessageConverter
import org.springframework.http.server.ServerHttpRequest
import org.springframework.http.server.ServerHttpResponse
import org.springframework.web.bind.annotation.ControllerAdvice
import org.springframework.web.servlet.mvc.method.annotation.ResponseBodyAdvice

@ControllerAdvice
class EitherResponseBodyAdvice : ResponseBodyAdvice<Any> {

    override fun supports(
        returnType: MethodParameter,
        converterType: Class<out HttpMessageConverter<*>>
    ): Boolean {
        // Apply this advice only if the controller returns either
        // TODO: throw an exception when the controller does not return either!
        return Either::class.java.isAssignableFrom(returnType.parameterType)
    }

    override fun beforeBodyWrite(
        body: Any?,
        returnType: MethodParameter,
        selectedContentType: MediaType,
        selectedConverterType: Class<out HttpMessageConverter<*>>,
        request: ServerHttpRequest,
        response: ServerHttpResponse
    ): Any? {
        if (body is Either<*, *>) {
            @Suppress("UNCHECKED_CAST")
            val either = body as? Either<SynciError, *>
                ?: return body

            return either.fold(
                { error ->
                    // the advice can only influence the body; the HTTP status has to be set on the response itself,
                    // otherwise every error would leave the server as 200
                    val entity = ErrorHandler.handle(error)
                    response.setStatusCode(entity.statusCode)
                    entity
                },
                { success -> ResponseEntity.ok(success) }
            )
        }
        return body
    }
}