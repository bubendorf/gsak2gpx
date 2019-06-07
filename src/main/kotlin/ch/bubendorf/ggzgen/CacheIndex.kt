package ch.bubendorf.ggzgen

import org.apache.commons.lang.StringEscapeUtils
import java.text.NumberFormat
import java.util.*

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
                "<file_pos>$filePos</file_pos>" +
                "<file_len>$fileLen</file_len>" +
                "<ratings>" +
//                "<awesomeness>${awesomeness.toSimlpeString()}</awesomeness>" +
                "<difficulty>${difficulty.toSimlpeString()}</difficulty>" +
                "<size>$size</size>" +
                "<terrain>${terrain.toSimlpeString()}</terrain>" +
                "</ratings>" +
                "</gch>\n"
    }

    private fun Double.toSimlpeString():String {
        return simpleStringFormat.format(this)
    }

    companion object {
        val simpleStringFormat = NumberFormat.getInstance(Locale.ROOT)
        init {
            simpleStringFormat.minimumFractionDigits  = 0
            simpleStringFormat.maximumFractionDigits = 1
        }
    }
}
