package com.dam.starwarsapp.domain.model

/**
 * Normalized video provider errors.
 */
data class VideoError(
    val kind: Kind,
    val message: String? = null,
    val rawCode: Int? = null,
) {
    enum class Kind {
        AuthMissing,
        Quota,
        RegionBlocked,
        NotFound,
        Network,
        ProviderUnsupported,
        Unknown,
    }
}
