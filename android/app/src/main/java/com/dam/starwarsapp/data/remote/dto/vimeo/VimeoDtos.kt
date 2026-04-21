package com.dam.starwarsapp.data.remote.dto.vimeo

import com.squareup.moshi.Json

data class VimeoSearchResponseDto(
    val data: List<VimeoVideoItemDto> = emptyList(),
)

data class VimeoVideoItemDto(
    val uri: String? = null,
    val link: String? = null,
    val name: String? = null,
)

data class VimeoVideoDetailsDto(
    val uri: String? = null,
    val link: String? = null,
    val name: String? = null,
    val play: VimeoPlayDto? = null,
)

data class VimeoPlayDto(
    val progressive: List<VimeoProgressiveDto> = emptyList(),
)

data class VimeoProgressiveDto(
    val link: String? = null,
    val height: Int? = null,
    val quality: String? = null,
    @Json(name = "mime") val mime: String? = null,
    val type: String? = null,
)
