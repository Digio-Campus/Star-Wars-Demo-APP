package com.dam.starwarsapp.data.remote.dto.youtube

data class YouTubeSearchResponseDto(
    val items: List<YouTubeSearchItemDto> = emptyList()
)

data class YouTubeSearchItemDto(
    val id: YouTubeIdDto? = null,
    val snippet: YouTubeSnippetDto? = null
)

data class YouTubeIdDto(
    val videoId: String? = null
)

data class YouTubeSnippetDto(
    val title: String? = null,
    val thumbnails: YouTubeThumbnailsDto? = null
)

data class YouTubeThumbnailsDto(
    val default: YouTubeThumbnailDto? = null
)

data class YouTubeThumbnailDto(
    val url: String? = null
)
