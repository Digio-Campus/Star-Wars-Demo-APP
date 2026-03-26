package com.dam.starwarsapp.ui.theme

import android.os.Build
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.platform.LocalContext

private val StarWarsDarkColorScheme = darkColorScheme(
    primary = SwYellow,
    onPrimary = SwBlack,
    secondary = SwYellow,
    onSecondary = SwBlack,
    background = SwBlack,
    onBackground = SwWhite,
    surface = SwSurface,
    onSurface = SwWhite,
    surfaceVariant = SwSurfaceVariant,
    onSurfaceVariant = SwWhite,
    outline = SwYellow,
)

private val StarWarsLightColorScheme = lightColorScheme(
    primary = SwYellow,
    onPrimary = SwBlack,
    secondary = SwYellow,
    onSecondary = SwBlack,
    background = SwBlack,
    onBackground = SwWhite,
    surface = SwSurface,
    onSurface = SwWhite,
    surfaceVariant = SwSurfaceVariant,
    onSurfaceVariant = SwWhite,
    outline = SwYellow,
)

@Composable
fun StarWarsAppTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    // Keep Star Wars palette by default.
    dynamicColor: Boolean = false,
    content: @Composable () -> Unit,
) {
    val colorScheme = when {
        dynamicColor && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> {
            val context = LocalContext.current
            if (darkTheme) dynamicDarkColorScheme(context) else dynamicLightColorScheme(context)
        }

        darkTheme -> StarWarsDarkColorScheme
        else -> StarWarsLightColorScheme
    }

    MaterialTheme(
        colorScheme = colorScheme,
        typography = Typography,
        content = content,
    )
}
