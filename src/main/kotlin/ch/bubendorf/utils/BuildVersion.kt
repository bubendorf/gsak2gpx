package ch.bubendorf.utils

class BuildVersion {

    companion object {
        fun getBuildVersion(): String {
            val version = BuildVersion::class.java.`package`.implementationVersion
            return if (version == null) "dev" else version
        }
    }
}


