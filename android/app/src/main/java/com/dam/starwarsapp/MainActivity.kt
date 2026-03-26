package com.dam.starwarsapp

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import androidx.navigation.compose.rememberNavController
import com.dam.starwarsapp.ui.navigation.StarWarsNavGraph
import com.dam.starwarsapp.ui.theme.StarWarsAppTheme
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // AndroidX SplashScreen
        installSplashScreen()

        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        setContent {
            StarWarsAppTheme {
                val navController = rememberNavController()
                StarWarsNavGraph(navController = navController)
            }
        }
    }
}
