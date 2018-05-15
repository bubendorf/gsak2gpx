package ch.bubendorf.ggzgen

import ch.bubendorf.utils.BuildVersion
import com.beust.jcommander.JCommander
import org.apache.commons.io.FilenameUtils
import org.apache.commons.io.output.CountingOutputStream
import org.slf4j.LoggerFactory
import java.io.*
import java.text.DecimalFormat
import java.util.*
import java.util.regex.Pattern
import java.util.zip.CRC32
import java.util.zip.CheckedOutputStream
import java.util.zip.ZipEntry
import java.util.zip.ZipOutputStream

fun main(args: Array<String>) {
    GGZGen().ggzgen(args)
}

/**
 * Converts a single GPX file with Geocaches into a GGZ file.
 * Uses regular expressions to parse the GPX XML file and works best
 * with the ouput from gsak2gpx.
 */
class GGZGen {

    private var header = ""
    private var footer: String? = null

    private var tagCount = 0
    private var totalCacheCount = 0
    private var inHeader = true
    private var writer: Writer? = null
    private val cmdArgs: CommandLineArguments = CommandLineArguments()

    private var zipStream: ZipOutputStream? = null
    private var zipCountingStream: CountingOutputStream? = null
    private var lastEntryZipStreamPosition = 0
    private var checkedStream: CheckedOutputStream? = null
    private var entryCountingStream: CountingOutputStream? = null
    private var zipEntry: ZipEntry? = null

    private var fileIndex: FileIndex = FileIndex("")
    private val fileIndices = ArrayList<FileIndex>()
    private var cacheIndex: CacheIndex? = null

    private val indexFile: String
        get() {
            val sb = StringBuilder(8192)
            sb.append("<ggz>\n")
            for (fileIndex in fileIndices) {
                sb.append(fileIndex.toXML())
            }
            sb.append("</ggz>\n")
            return sb.toString()
        }

    fun ggzgen(args: Array<String>) {
        val jCommander = JCommander(cmdArgs)
        jCommander.parse(*args)

        if (cmdArgs.isHelp) {
            jCommander.usage()
            System.exit(1)
        }

        if (!cmdArgs.isValid) {
            System.exit(2)
        }

        LOGGER.info("Start GGZgen Version ${BuildVersion.getBuildVersion()} for ${cmdArgs.output}")
        val reader = if ("-" == cmdArgs.input) {
            BufferedReader(InputStreamReader(System.`in`, cmdArgs.encoding))
        } else {
            BufferedReader(InputStreamReader(FileInputStream(cmdArgs.input), cmdArgs.encoding), 65536)
        }
        reader.forEachLine { rawline ->
            val line = rawline.trim { it <= ' ' }
            if (line.length > 0) {

                if (inHeader && CACHE_WAYPOINT_PATTERN.matcher(line).matches()) {
                    inHeader = false
                    openZipFile()
                    openZipEntry()
                }
                if (inHeader) {
                    header = header + line + "\n"
                    if (footer == null && line.startsWith("<") && !line.startsWith("<?")) {
                        // Das Root-Tag für den Footer extrahieren
                        val pattern = Pattern.compile("^\\s*<\\s*(\\w*)\\W.*$")
                        val matcher = pattern.matcher(line)
                        if (matcher.matches()) {
                            footer = "</" + matcher.group(1) + ">"
                        }
                    }
                } else {
                    if (CACHE_WAYPOINT_PATTERN.matcher(line).matches()) {
                        // Start Tag
                        tagCount++
                        nextCacheIndex()
                        if (tagCount >= cmdArgs.count || entryCountingStream!!.count >= cmdArgs.size) {
                            // Maximale Grösse erreicht ==> Neue Datei eröffnen
                            openZipEntry()
                        }
                        totalCacheCount++
                    }

                    val codeMatcher = CACHE_CODE_PATTERN.matcher(line)
                    if (codeMatcher.find()) {
                        cacheIndex!!.code = codeMatcher.group(1)
                    }
                    val nameMatcher = CACHE_NAME_PATTERN.matcher(line)
                    if (nameMatcher.find()) {
                        cacheIndex!!.name = nameMatcher.group(1)
                    }
                    val typeMatcher = CACHE_TYPE_PATTERN.matcher(line)
                    if (typeMatcher.find()) {
                        cacheIndex!!.type = typeMatcher.group(1)
                    }
                    val latMatcher = CACHE_LAT_PATTERN.matcher(line)
                    if (latMatcher.find()) {
                        cacheIndex!!.lat = java.lang.Double.parseDouble(latMatcher.group(1))
                    }
                    val lonMatcher = CACHE_LON_PATTERN.matcher(line)
                    if (lonMatcher.find()) {
                        cacheIndex!!.lon = java.lang.Double.parseDouble(lonMatcher.group(1))
                    }
                    val diffMatcher = CACHE_DIFFICULTY_PATTERN.matcher(line)
                    if (diffMatcher.find()) {
                        cacheIndex!!.difficulty = java.lang.Double.parseDouble(diffMatcher.group(1))
                    }
                    val terrMatcher = CACHE_TERRAIN_PATTERN.matcher(line)
                    if (terrMatcher.find()) {
                        cacheIndex!!.terrain = java.lang.Double.parseDouble(terrMatcher.group(1))
                    }
                    val sizeMatcher = CACHE_SIZE_PATTERN.matcher(line)
                    if (sizeMatcher.find()) {
                        cacheIndex!!.size = CONTAINER_SIZE_MAP.getOrDefault(sizeMatcher.group(1).toLowerCase(), -1)
                    }

                    writer!!.write(line)
                    writer!!.write("\n")
                }
            }
        }

        footer = ""
        nextCacheIndex()
        closeZipEntry()
        LOGGER.info("Finished GGZgen (${FilenameUtils.getName(cmdArgs.output)}) with ${totalCacheCount} entries.")
        reader.close()
        closeZipFile()
    }

    private fun nextCacheIndex() {
        writer!!.flush()
        if (cacheIndex != null) {
            cacheIndex!!.awesomeness = 3.0
            cacheIndex!!.fileLen = entryCountingStream!!.count - cacheIndex!!.filePos
            fileIndex.addCacheIndex(cacheIndex!!)
        }
        cacheIndex = CacheIndex()
        cacheIndex!!.filePos = entryCountingStream!!.count
    }

    private fun openZipFile() {
        val fileOutputStream = FileOutputStream(cmdArgs.output!!)
        val bufferedStream = BufferedOutputStream(fileOutputStream, 65536)
        zipCountingStream = CountingOutputStream(bufferedStream)
        zipStream = ZipOutputStream(zipCountingStream!!)
        zipStream!!.setLevel(9)
        zipStream!!.setComment("ggzgen V${BuildVersion.getBuildVersion()} by Markus Bubendorf")
    }

    private fun closeZipFile() {
        zipEntry = ZipEntry("index/com/garmin/geocaches/v0/index.xml")
        zipStream!!.putNextEntry(zipEntry!!)
        writer = OutputStreamWriter(zipStream!!, cmdArgs.encoding)
        val indexFile = indexFile
        writer!!.write(indexFile)
        writer!!.flush()
        zipStream!!.closeEntry()
        zipStream!!.close()
    }

    private fun openZipEntry() {
        closeZipEntry()

        val fileName = if ("-" == cmdArgs.input) "stdin.gpx" else cmdArgs.input
        val ext = FilenameUtils.getExtension(fileName)
        val basename = FilenameUtils.getBaseName(fileName)
        val newFileName = String.format(cmdArgs.format, basename, fileIndices.size, ext)

        LOGGER.debug("New file: " + newFileName)
        zipEntry = ZipEntry("data/" + newFileName)
        zipStream!!.putNextEntry(zipEntry!!)

        fileIndex = FileIndex(newFileName)
        fileIndices.add(fileIndex)

        entryCountingStream = CountingOutputStream(zipStream)
        checkedStream = CheckedOutputStream(entryCountingStream, CRC32())
        writer = OutputStreamWriter(checkedStream!!, cmdArgs.encoding)
        writer!!.write(header)
        tagCount = 0
    }

    private fun closeZipEntry() {
        if (writer != null) {
            writer!!.write(footer!!)
            writer!!.flush()
            checkedStream!!.flush()
            fileIndex.crc = java.lang.Long.toHexString(checkedStream!!.checksum.value)
            writer = null
            zipStream!!.closeEntry()
            zipEntry = null

            val oneDigitNumberFormat = DecimalFormat("0.0")
            val currentZipStreamPosition = zipCountingStream!!.count
            val zipSizeOfEntry = currentZipStreamPosition - lastEntryZipStreamPosition
            LOGGER.info(
                    FilenameUtils.getName(cmdArgs.output) + "(" +
                            fileIndex.name + "):" +
                            "Count=" + fileIndex.cacheIndexSize +
                            ",Total=" + totalCacheCount +
                            ",Filesize=" + entryCountingStream!!.count +
                            ",OnDisk=" + zipSizeOfEntry + " (" + oneDigitNumberFormat.format(100.0 / entryCountingStream!!.count * zipSizeOfEntry) + "%)")
            lastEntryZipStreamPosition = currentZipStreamPosition
        }
    }

    companion object {

        private val LOGGER = LoggerFactory.getLogger(GGZGen::class.java.simpleName)

        private val CACHE_CODE_PATTERN = Pattern.compile("<name>(\\w*)</name>")
        private val CACHE_NAME_PATTERN = Pattern.compile("<desc>(.*)</desc>")
        private val CACHE_TYPE_PATTERN = Pattern.compile("<type>Geocache.(.+)</type>")
        private val CACHE_LAT_PATTERN = Pattern.compile("wpt.*lat=\"([0-9.]*)\"")
        private val CACHE_LON_PATTERN = Pattern.compile("wpt.*lon=\"([0-9.]*)\"")
        private val CACHE_DIFFICULTY_PATTERN = Pattern.compile("<groundspeak:difficulty>([0-9.]*)</groundspeak:difficulty>")
        private val CACHE_SIZE_PATTERN = Pattern.compile("<groundspeak:container>(\\w*)</groundspeak:container>")
        private val CACHE_TERRAIN_PATTERN = Pattern.compile("<groundspeak:terrain>([0-9.]*)</groundspeak:terrain>")

        private val CACHE_WAYPOINT_PATTERN = Pattern.compile("^\\s*<\\s*wpt\\W.*$")

        val CONTAINER_SIZE_MAP: Map<String, Int> = hashMapOf(
                "micro" to 2,
                "small" to 3,
                "regular" to 4,
                "large" to 5,
                "other" to -1,
                "not chosen" to -2,
                "virtual" to 0,
                "unknown" to 0
        )

    }
}
