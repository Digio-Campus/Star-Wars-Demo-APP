package com.dam.starwarsapp.util

/**
 * Logging helper that is safe to call from JVM unit tests.
 *
 * In local unit tests, android.util.Log methods throw "not mocked" RuntimeExceptions.
 * We catch those and fallback to stdout so tests keep running.
 */
object AppLog {
    private fun fallback(level: String, tag: String, message: String, tr: Throwable? = null) {
        val base = "$level/$tag: $message"
        if (tr != null) {
            println(base)
            println(tr.stackTraceToString())
        } else {
            println(base)
        }
    }

    fun d(tag: String, message: String) {
        runCatching { android.util.Log.d(tag, message) }
            .getOrElse { fallback("D", tag, message, it) }
    }

    fun i(tag: String, message: String) {
        runCatching { android.util.Log.i(tag, message) }
            .getOrElse { fallback("I", tag, message, it) }
    }

    fun w(tag: String, message: String, tr: Throwable? = null) {
        val res = if (tr == null) {
            runCatching { android.util.Log.w(tag, message) }
        } else {
            runCatching { android.util.Log.w(tag, message, tr) }
        }
        res.getOrElse { fallback("W", tag, message, tr ?: it) }
    }

    fun e(tag: String, message: String, tr: Throwable? = null) {
        val res = if (tr == null) {
            runCatching { android.util.Log.e(tag, message) }
        } else {
            runCatching { android.util.Log.e(tag, message, tr) }
        }
        res.getOrElse { fallback("E", tag, message, tr ?: it) }
    }
}
