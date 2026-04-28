package com.dam.starwarsapp.data.provider

import com.squareup.moshi.JsonClass

@JsonClass(generateAdapter = true)
data class YouTubeSearchResponse(val items: List<YouTubeItem>?)

@JsonClass(generateAdapter = true)
data class YouTubeItem(val id: YouTubeId?, val snippet: YouTubeSnippet?)

@JsonClass(generateAdapter = true)
data class YouTubeId(val kind: String?, val videoId: String?)

@JsonClass(generateAdapter = true)
data class YouTubeSnippet(val title: String?)
