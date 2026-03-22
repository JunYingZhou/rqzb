package com.example.renqing_ledger

import android.graphics.Point

data class PaddleOcrResult(
    val index: Int,
    val name: String,
    val confidence: Float,
    val bounds: MutableList<Point>,
)
