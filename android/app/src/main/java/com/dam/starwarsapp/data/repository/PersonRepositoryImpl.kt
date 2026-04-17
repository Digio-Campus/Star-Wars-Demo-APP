package com.dam.starwarsapp.data.repository

import com.dam.starwarsapp.data.local.PersonDao
import com.dam.starwarsapp.data.mapper.toDomain
import com.dam.starwarsapp.data.mapper.toEntity
import com.dam.starwarsapp.data.remote.SwapiService
import com.dam.starwarsapp.domain.model.Person
import com.dam.starwarsapp.domain.repository.PersonRepository
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.withContext
import javax.inject.Inject

class PersonRepositoryImpl @Inject constructor(
    private val dao: PersonDao,
    private val service: SwapiService,
) : PersonRepository {

    override fun observePeople(): Flow<List<Person>> = dao.observeAll().map { list ->
        list.map { it.toDomain() }
    }

    override fun observePerson(id: Int): Flow<Person?> = dao.observeById(id).map { it?.toDomain() }

    override suspend fun refreshPeople(): Result<Unit> = withContext(Dispatchers.IO) {
        runCatching {
            val entities = service.getPeople().map { it.toEntity() }
            dao.upsertAll(entities)
        }
    }

    override suspend fun deletePerson(id: Int) {
        withContext(Dispatchers.IO) {
            dao.deleteById(id)
        }
    }

}
