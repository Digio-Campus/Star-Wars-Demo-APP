package com.dam.starwarsapp

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.viewModels
import androidx.compose.runtime.getValue
import androidx.compose.runtime.collectAsState
import com.dam.starwarsapp.domain.model.ThemeMode
import com.dam.starwarsapp.ui.StarWarsAppContent
import com.dam.starwarsapp.ui.screens.settings.SettingsViewModel
import com.dam.starwarsapp.ui.theme.StarWarsAppTheme
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MainActivity : ComponentActivity() {

    private val settingsViewModel: SettingsViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        setContent {
            val themeMode by settingsViewModel.themeMode.collectAsState()

            StarWarsAppTheme(
                darkTheme = themeMode == ThemeMode.DARK,
            ) {
                StarWarsAppContent()
            }
        }
    }
}
