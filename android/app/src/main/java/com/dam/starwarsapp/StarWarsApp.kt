package com.dam.starwarsapp

import android.app.Application
import dagger.hilt.android.HiltAndroidApp

@HiltAndroidApp
class StarWarsApp : Application() {
    override fun onCreate() {
        super.onCreate()
        // Lazy init so Cast button works without needing any specific screen ordering.
        runCatching { com.google.android.gms.cast.framework.CastContext.getSharedInstance(this) }
    }
}
