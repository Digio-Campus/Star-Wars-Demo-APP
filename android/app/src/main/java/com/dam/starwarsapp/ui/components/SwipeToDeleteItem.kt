package com.dam.starwarsapp.ui.components

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeOut
import androidx.compose.animation.shrinkVertically
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material.DismissDirection
import androidx.compose.material.DismissState
import androidx.compose.material.DismissValue
import androidx.compose.material.ExperimentalMaterialApi
import androidx.compose.material.SwipeToDismiss
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp

@OptIn(ExperimentalMaterialApi::class)
@Composable
fun SwipeToDeleteItem(
    itemKey: Any,
    modifier: Modifier = Modifier,
    onDelete: () -> Unit,
    content: @Composable () -> Unit,
) {
    var isRemoved by remember(itemKey) { mutableStateOf(false) }
    val onDeleteState = rememberUpdatedState(onDelete)

    val dismissState = remember(itemKey) {
        DismissState(
            initialValue = DismissValue.Default,
            confirmStateChange = { value ->
                if (value == DismissValue.DismissedToStart && !isRemoved) {
                    isRemoved = true
                    // Important: call delete immediately. If we delay inside a composable scope,
                    // the coroutine may be cancelled when the item leaves composition.
                    onDeleteState.value.invoke()
                }
                // Permit resetting back to Default; otherwise items can get stuck "half swiped".
                true
            },
        )
    }

    AnimatedVisibility(
        visible = !isRemoved,
        modifier = modifier,
        exit = shrinkVertically(animationSpec = tween(250)) + fadeOut(animationSpec = tween(250)),
    ) {
        SwipeToDismiss(
            state = dismissState,
            directions = setOf(DismissDirection.EndToStart),
            background = {
                val bg = if (dismissState.dismissDirection == DismissDirection.EndToStart) {
                    MaterialTheme.colorScheme.errorContainer
                } else {
                    Color.Transparent
                }

                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .background(bg)
                        .padding(end = 20.dp),
                    contentAlignment = Alignment.CenterEnd,
                ) {
                    Icon(
                        imageVector = Icons.Filled.Delete,
                        contentDescription = "Eliminar",
                        tint = MaterialTheme.colorScheme.error,
                    )
                }
            },
            dismissContent = {
                content()
            },
        )
    }
}
