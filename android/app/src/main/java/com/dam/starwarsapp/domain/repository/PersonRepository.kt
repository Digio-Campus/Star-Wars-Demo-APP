package com.dam.starwarsapp.domain.repository

import com.dam.starwarsapp.domain.model.Person
import kotlinx.coroutines.flow.Flow

interface PersonRepository {
    fun observePeople(): Flow<List<Person>>
    fun observePerson(id: Int): Flow<Person?>
    suspend fun refreshPeople(): Result<Unit>
}
