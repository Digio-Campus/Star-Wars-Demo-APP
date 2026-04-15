package com.dam.starwarsapp.ui.screens.detail

internal fun String.asDisplayValue(): String {
    val trimmed = trim()
    if (trimmed.isBlank()) return "—"

    return when (trimmed.lowercase()) {
        "unknown", "n/a", "none" -> "—"
        else -> trimmed
    }
}

internal fun Int.asDisplayValue(): String = toString()
