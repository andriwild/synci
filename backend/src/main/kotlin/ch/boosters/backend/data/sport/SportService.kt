package ch.boosters.backend.data.sport

import org.springframework.stereotype.Service

@Service
class SportService(
    private val sportRepository: SportRepository
) {
    fun getSubcategoriesOfCategory(): List<Sport> {
        val skiRoot = sportRepository.getSkiRoot() ?: return emptyList()
        return sportRepository.getSubcategoriesById(skiRoot.id)
    }
}
