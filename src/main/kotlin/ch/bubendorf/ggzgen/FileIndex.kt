package ch.bubendorf.ggzgen

class FileIndex(val name: String,
                private val gch: MutableList<CacheIndex> = ArrayList()) {
    var crc: String? = null

    val cacheIndexSize: Int
        get() = gch.size

    fun addCacheIndex(cacheIndex: CacheIndex) {
        gch.add(cacheIndex)
    }

    fun toXML(): String {
        val sb = StringBuilder()
        sb.append("<file>\n")
        sb.append("<name>").append(name).append("</name>\n")
        sb.append("<crc>").append(crc).append("</crc>\n")
        for (cacheIndex in gch) {
            sb.append(cacheIndex.toXML())
        }

        sb.append("</file>\n")
        return sb.toString()
    }
}
