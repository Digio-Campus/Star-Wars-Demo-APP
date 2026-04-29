package com.dam.starwarsapp.video

import android.content.Context
import android.widget.FrameLayout
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.LifecycleRegistry
import androidx.test.core.app.ApplicationProvider
import com.dam.starwarsapp.data.player.AndroidTrailerPlayer
import com.dam.starwarsapp.domain.video.VideoSource
import kotlinx.coroutines.runBlocking
import org.junit.Test
import org.junit.Assert.*
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class AndroidTrailerPlayerTest {

    @Test
    @org.junit.Ignore("Device-dependent: skipping ExoPlayer init in unit test environment")
    fun loadAndReleaseDirect() = runBlocking {
        val context = ApplicationProvider.getApplicationContext<Context>()
        val owner = object : LifecycleOwner {
            val registry = LifecycleRegistry(this).apply { currentState = Lifecycle.State.RESUMED }
            override val lifecycle: Lifecycle get() = registry
        }

        val container = FrameLayout(context)
        val player = AndroidTrailerPlayer(context, owner.lifecycle, container)

        // Use a small public MP4 for smoke-testing load/prepare
        player.load(VideoSource.Direct("https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"))
        player.play()
        player.pause()
        player.release()

        assertTrue(true) // reached without throwing
    }
}
