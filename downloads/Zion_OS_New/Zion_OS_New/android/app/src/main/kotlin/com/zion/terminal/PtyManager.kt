package com.zion.terminal

import android.util.Log

class PtyManager {
    private var statePtr: Long = 0
    var onOutput: ((String) -> Unit)? = null
    var onExit: ((Int) -> Unit)? = null
    
    companion object {
        init { System.loadLibrary("pty_bridge") }
    }
    
    private external fun nativePtyOpen(rows: Int, cols: Int, shellPath: String, shellArgs: Array<String>): Long
    private external fun nativePtyRead(statePtr: Long): String
    private external fun nativePtyWrite(statePtr: Long, data: String)
    private external fun nativePtyResize(statePtr: Long, rows: Int, cols: Int)
    private external fun nativePtyClose(statePtr: Long)
    
    fun open(rows: Int, cols: Int, shellPath: String, args: List<String>): Boolean {
        statePtr = nativePtyOpen(rows, cols, shellPath, args.toTypedArray())
        if (statePtr != 0L) startReaderThread()
        return statePtr != 0L
    }
    
    private fun startReaderThread() {
        Thread {
            while (statePtr != 0L) {
                val output = nativePtyRead(statePtr)
                if (output.isNotEmpty()) onOutput?.invoke(output)
            }
        }.start()
    }
    
    fun write(command: String) { if (statePtr != 0L) nativePtyWrite(statePtr, command) }
    fun resize(rows: Int, cols: Int) { if (statePtr != 0L) nativePtyResize(statePtr, rows, cols) }
    fun close() { if (statePtr != 0L) { nativePtyClose(statePtr); statePtr = 0L } }
}
