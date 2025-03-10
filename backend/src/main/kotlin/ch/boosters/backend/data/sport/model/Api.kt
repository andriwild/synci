package ch.boosters.backend.data.sport.model

import ch.boosters.data.tables.pojos.EventsTable

data class EventsBySportApi(
    val amount: Int,
    val page: Int,
    val pageSize: Int,
    val elements: List<EventsTable>
)