package ch.bubendorf.ggzgen

import org.apache.commons.lang.StringEscapeUtils

class CacheIndex {
    var code: String? = null
    var name: String? = null
    var type: String? = null
    var lat: Double = 0.0
    var lon: Double = 0.0
    var file_pos: Int = 0
    var file_len: Int = 0
    var awesomeness: Double = 0.0
    var difficulty: Double = 0.0
    var size: Int = 0
    var terrain: Double = 0.0

    fun toXML(): String {
        return "<gch>\n" +
                "<code>" + code + "</code>\n" +
                "<name>" + StringEscapeUtils.escapeXml(name) + "</name>\n" +
                "<type>" + type + "</type>\n" +
                "<lat>" + lat + "</lat>\n" +
                "<lon>" + lon + "</lon>\n" +
                "<file_pos>" + file_pos + "</file_pos>\n" +
                "<file_len>" + file_len + "</file_len>\n" +
                "<ratings>\n" +
                "<awesomeness>" + awesomeness + "</awesomeness>\n" +
                "<difficulty>" + difficulty + "</difficulty>\n" +
                "<size>" + size + "</size>\n" +
                "<terrain>" + terrain + "</terrain>\n" +
                "</ratings>\n" +
                "</gch>\n"
    }
}
