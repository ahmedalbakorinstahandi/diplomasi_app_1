package com.diplomasi.app

import com.ryanheise.audioservice.AudioServiceFragmentActivity

/**
 * Must extend [AudioServiceFragmentActivity] (not plain [FlutterFragmentActivity]) so the app
 * uses the same cached [FlutterEngine] that audio_service expects in
 * [com.ryanheise.audioservice.AudioServicePlugin]. Otherwise the plugin sets
 * wrongEngineDetected and configure() throws "Activity class … wrong".
 */
class MainActivity : AudioServiceFragmentActivity()
