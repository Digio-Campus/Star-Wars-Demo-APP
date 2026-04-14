package com.dam.starwarsapp.ui.navigation

import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavHostController
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.navArgument
import com.dam.starwarsapp.ui.screens.detail.FilmDetailScreen
import com.dam.starwarsapp.ui.screens.films.FilmsScreen
import com.dam.starwarsapp.ui.screens.people.PeopleScreen
import com.dam.starwarsapp.ui.screens.people.PersonDetailScreen
import com.dam.starwarsapp.ui.screens.planets.PlanetDetailScreen
import com.dam.starwarsapp.ui.screens.planets.PlanetsScreen
import com.dam.starwarsapp.ui.screens.settings.SettingsScreen
import com.dam.starwarsapp.ui.screens.splash.SplashScreen
import com.dam.starwarsapp.ui.screens.starships.StarshipDetailScreen
import com.dam.starwarsapp.ui.screens.starships.StarshipsScreen

@Composable
fun StarWarsNavGraph(
    navController: NavHostController,
    modifier: Modifier = Modifier,
) {
    NavHost(
        navController = navController,
        startDestination = Destinations.Splash,
        modifier = modifier,
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

        composable(Destinations.Starships) {
            StarshipsScreen(
                viewModel = hiltViewModel(),
                onStarshipClick = { id -> navController.navigate(Destinations.starshipDetailRoute(id)) },
            )
        }

        composable(Destinations.Planets) {
            PlanetsScreen(
                viewModel = hiltViewModel(),
                onPlanetClick = { id -> navController.navigate(Destinations.planetDetailRoute(id)) },
            )
        }

        composable(Destinations.People) {
            PeopleScreen(
                viewModel = hiltViewModel(),
                onPersonClick = { id -> navController.navigate(Destinations.personDetailRoute(id)) },
            )
        }

        composable(Destinations.Settings) {
            SettingsScreen(viewModel = hiltViewModel())
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

        composable(
            route = "${Destinations.StarshipDetail}/{${Destinations.starshipIdArg}}",
            arguments = listOf(navArgument(Destinations.starshipIdArg) { type = NavType.IntType }),
        ) {
            StarshipDetailScreen(
                viewModel = hiltViewModel(),
                onBack = { navController.popBackStack() },
            )
        }

        composable(
            route = "${Destinations.PlanetDetail}/{${Destinations.planetIdArg}}",
            arguments = listOf(navArgument(Destinations.planetIdArg) { type = NavType.IntType }),
        ) {
            PlanetDetailScreen(
                viewModel = hiltViewModel(),
                onBack = { navController.popBackStack() },
            )
        }

        composable(
            route = "${Destinations.PersonDetail}/{${Destinations.personIdArg}}",
            arguments = listOf(navArgument(Destinations.personIdArg) { type = NavType.IntType }),
        ) {
            PersonDetailScreen(
                viewModel = hiltViewModel(),
                onBack = { navController.popBackStack() },
            )
        }
    }
}
