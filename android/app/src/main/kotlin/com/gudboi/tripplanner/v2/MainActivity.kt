package com.gudboi.tripplanner.v2

import android.content.ContentValues
import android.os.Build
import android.provider.MediaStore
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.io.BufferedInputStream

class MainActivity : FlutterActivity() {
    private val channelName = "trip_planner/media_scanner"
    private val TAG = "TripPlanner"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "saveToGallery" -> {
                        val sourcePath = call.argument<String>("sourcePath")
                        val fileName = call.argument<String>("fileName")
                        val mimeType = call.argument<String>("mimeType") ?: "image/jpeg"

                        if (sourcePath.isNullOrBlank() || fileName.isNullOrBlank()) {
                            result.error("INVALID_ARGS", "sourcePath and fileName are required", null)
                            return@setMethodCallHandler
                        }

                        try {
                            val savedUri = saveToMediaStore(sourcePath, fileName, mimeType)
                            if (savedUri != null) {
                                Log.d(TAG, "Photo saved to gallery: $savedUri")
                                result.success(savedUri)
                            } else {
                                Log.e(TAG, "saveToMediaStore returned null")
                                result.error("SAVE_FAILED", "Failed to save to MediaStore", null)
                            }
                        } catch (e: Exception) {
                            Log.e(TAG, "saveToGallery exception: ${e.message}", e)
                            result.error("EXCEPTION", e.message, e.stackTraceToString())
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun saveToMediaStore(sourcePath: String, fileName: String, mimeType: String): String? {
        val sourceFile = File(sourcePath)
        if (!sourceFile.exists()) {
            Log.e(TAG, "Source file does not exist: $sourcePath")
            return null
        }
        Log.d(TAG, "Source file exists: $sourcePath, size=${sourceFile.length()}")

        val contentValues = ContentValues().apply {
            put(MediaStore.Images.Media.DISPLAY_NAME, fileName)
            put(MediaStore.Images.Media.MIME_TYPE, mimeType)
            put(MediaStore.Images.Media.RELATIVE_PATH, "Pictures/Trip Planner")
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                put(MediaStore.Images.Media.IS_PENDING, 1)
            }
        }

        val resolver = contentResolver
        val collection = MediaStore.Images.Media.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
        val uri = resolver.insert(collection, contentValues)
        if (uri == null) {
            Log.e(TAG, "MediaStore insert returned null URI")
            return null
        }
        Log.d(TAG, "MediaStore URI created: $uri")

        var bytesWritten = 0L
        resolver.openOutputStream(uri)?.use { outputStream ->
            FileInputStream(sourceFile).use { fileInput ->
                BufferedInputStream(fileInput).use { bufferedInput ->
                    val buffer = ByteArray(8192)
                    var bytesRead: Int
                    while (bufferedInput.read(buffer).also { bytesRead = it } != -1) {
                        outputStream.write(buffer, 0, bytesRead)
                        bytesWritten += bytesRead
                    }
                    outputStream.flush()
                }
            }
        } ?: run {
            Log.e(TAG, "Failed to open output stream for URI: $uri")
            resolver.delete(uri, null, null)
            return null
        }

        Log.d(TAG, "Bytes written to MediaStore: $bytesWritten")

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            contentValues.clear()
            contentValues.put(MediaStore.Images.Media.IS_PENDING, 0)
            val updated = resolver.update(uri, contentValues, null, null)
            Log.d(TAG, "IS_PENDING cleared, rows updated: $updated")
        }

        return uri.toString()
    }
}
