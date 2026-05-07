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
    val default: YouTubeThumbnailDto? = null,
    val medium: YouTubeThumbnailDto? = null,
    val high: YouTubeThumbnailDto? = null,
)

data class YouTubeThumbnailDto(
    val url: String? = null
)

// videos.list DTOs

data class YouTubeVideosResponseDto(
    val items: List<YouTubeVideoItemDto> = emptyList(),
)

data class YouTubeVideoItemDto(
    val id: String? = null,
    val status: YouTubeVideoStatusDto? = null,
    val contentDetails: YouTubeVideoContentDetailsDto? = null,
)

data class YouTubeVideoStatusDto(
    val embeddable: Boolean? = null,
    val privacyStatus: String? = null,
)

data class YouTubeVideoContentDetailsDto(
    val contentRating: YouTubeContentRatingDto? = null,
    val regionRestriction: YouTubeRegionRestrictionDto? = null,
)

data class YouTubeContentRatingDto(
    val ytRating: String? = null,
)

data class YouTubeRegionRestrictionDto(
    val blocked: List<String>? = null,
    val allowed: List<String>? = null,
)
