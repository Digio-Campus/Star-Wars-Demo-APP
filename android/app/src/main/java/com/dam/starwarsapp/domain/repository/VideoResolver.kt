package com.dam.starwarsapp.domain.repository

import com.dam.starwarsapp.domain.model.ResolvedVideo

/**
 * Orchestrator that selects a provider and resolves a playable target for a title.
 */
interface VideoResolver {
    suspend fun resolve(title: String): ResolvedVideo?
}
