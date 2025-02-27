package ch.boosters.backend.data.sport

import java.util.*

data class Sport (
    val id: UUID,
    val parentId: UUID?,
    val name: String
)
