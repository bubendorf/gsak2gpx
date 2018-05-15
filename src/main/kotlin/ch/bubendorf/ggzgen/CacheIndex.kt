package ch.bubendorf.ggzgen

import org.apache.commons.lang.StringEscapeUtils

/**
 * Simple data class for a single geocache.
 * Used to produce the GGZ Index.
 */
open class CacheIndex {
    var code: String? = null
    var name: String? = null
    var type: String? = null
    var lat: Double = 0.0
    var lon: Double = 0.0
    var filePos: Int = 0
    var fileLen: Int = 0
    var awesomeness: Double = 0.0
    var difficulty: Double = 0.0
    var size: Int = 0
    var terrain: Double = 0.0

    fun toXML(): CharSequence {
        return "<gch>" +
                "<code>$code</code>" +
                "<name>${StringEscapeUtils.escapeXml(name)}</name>" +
                "<type>$type</type>" +
                "<lat>$lat</lat>" +
                "<lon>$lon</lon>" +
                "<filePos>$filePos</filePos>" +
                "<fileLen>$fileLen</fileLen>" +
                "<ratings>" +
                "<awesomeness>$awesomeness</awesomeness>" +
                "<difficulty>$difficulty</difficulty>" +
                "<size>$size</size>" +
                "<terrain>$terrain</terrain>" +
                "</ratings>" +
                "</gch>\n"
    }
}
