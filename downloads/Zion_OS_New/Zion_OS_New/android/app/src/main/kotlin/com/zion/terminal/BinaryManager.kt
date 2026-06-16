package com.zion.terminal

import android.content.Context
import java.io.File
import java.io.FileOutputStream

class BinaryManager(private val context: Context) {
    private val filesDir: File get() = context.filesDir
    
    fun extractBinary(assetName: String, targetName: String): File {
        val targetFile = File(filesDir, targetName)
        if (targetFile.exists()) return targetFile
        
        context.assets.open(assetName).use { input ->
            FileOutputStream(targetFile).use { output -> input.copyTo(output) }
        }
        
        targetFile.setExecutable(true, false)
        targetFile.setReadable(true, false)
        targetFile.setWritable(false, false)
        
        return targetFile
    }
    
    fun extractAll(): Map<String, File> {
        val arch = if (System.getProperty("os.arch")?.contains("64") == true) "aarch64" else "armv7l"
        return mapOf(
            "bash" to extractBinary("binaries/bash/$arch/bash", "bash"),
            "proot" to extractBinary("binaries/proot/$arch/proot", "proot"),
            "busybox" to extractBinary("binaries/busybox/$arch/busybox", "busybox")
        )
    }
}
