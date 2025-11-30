package ch.boosters.backend.data.sport.model

data class PagedResult<T>(
    val amount: Int,
    val page: Int,
    val pageSize: Int,
    val elements: List<T>
)