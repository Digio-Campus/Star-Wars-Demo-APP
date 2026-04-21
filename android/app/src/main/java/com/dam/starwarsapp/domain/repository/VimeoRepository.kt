package com.dam.starwarsapp.domain.repository

import com.dam.starwarsapp.domain.model.VimeoVideo
import kotlinx.coroutines.flow.Flow

interface VimeoRepository {
    fun searchVimeoVideo(filmTitle: String): Flow<VimeoVideo?>
}
