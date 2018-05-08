package ch.bubendorf.gsak2gpx

class MbuHelper {
    fun substring(text: String, start: Int, end: Int): String {
        val realEnd = Math.min(end, text.length)
        return text.substring(start, realEnd)
    }

    fun oneline(text: String) : String {
        return text.replace("\n", "").replace("\r", "")
    }
}
