package com.dam.starwarsapp.ui.navigation

import androidx.compose.runtime.Composable
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavHostController
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.navArgument
import com.dam.starwarsapp.ui.screens.detail.FilmDetailScreen
import com.dam.starwarsapp.ui.screens.films.FilmsScreen
import com.dam.starwarsapp.ui.screens.splash.SplashScreen

@Composable
fun StarWarsNavGraph(
    navController: NavHostController,
) {
    NavHost(
        navController = navController,
        startDestination = Destinations.Splash,
    ) {
        composable(Destinations.Splash) {
            SplashScreen(
                onFinished = {
                    navController.navigate(Destinations.Films) {
                        popUpTo(Destinations.Splash) { inclusive = true }
                    }
                },
            )
        }

        composable(Destinations.Films) {
            FilmsScreen(
                viewModel = hiltViewModel(),
                onFilmClick = { filmId -> navController.navigate(Destinations.filmDetailRoute(filmId)) },
            )
        }

        composable(
            route = "${Destinations.FilmDetail}/{${Destinations.filmIdArg}}",
            arguments = listOf(navArgument(Destinations.filmIdArg) { type = NavType.IntType }),
        ) {
            FilmDetailScreen(
                viewModel = hiltViewModel(),
                onBack = { navController.popBackStack() },
            )
        }
    }
}
