package ch.bubendorf.gsak2gpx

import ch.bubendorf.smartnames.NameCalculator

class MbuHelper {
    val nameCalculator = NameCalculator()

    fun substring(text: String, start: Int, end: Int): String {
        val realEnd = Math.min(end, text.length)
        return text.substring(start, realEnd)
    }

    fun oneline(text: String) : String {
        return text.replace("\n", "").replace("\r", "")
    }

    fun smartname(value: String, maxLength: Int): String {
        nameCalculator.maxLength = maxLength
        nameCalculator.force = true
        return nameCalculator.calculate(value)
    }

}
