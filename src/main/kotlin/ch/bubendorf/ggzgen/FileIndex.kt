package ch.bubendorf.ggzgen

/**
 * Represents the index into the GPX files.
 */
open class FileIndex(val name: String,
                private val gch: MutableList<CacheIndex> = ArrayList()) {
    var crc: String? = null

    val cacheIndexSize: Int
        get() = gch.size

    fun addCacheIndex(cacheIndex: CacheIndex) {
        gch.add(cacheIndex)
    }

    fun toXML(): CharSequence {
        val sb = StringBuilder(8192)
        sb.append("<file>\n")
        sb.append("<name>$name</name>\n")
        sb.append("<crc>$crc</crc>\n")
        for (cacheIndex in gch) {
            sb.append(cacheIndex.toXML())
        }

        sb.append("</file>\n")
        return sb
    }
}
