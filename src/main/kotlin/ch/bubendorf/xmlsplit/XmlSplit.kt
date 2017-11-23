package ch.bubendorf.xmlsplit

import com.beust.jcommander.JCommander
import org.apache.commons.io.FilenameUtils
import org.slf4j.LoggerFactory
import java.io.*
import java.util.regex.Pattern


object XmlSplit {

    private val LOGGER = LoggerFactory.getLogger(XmlSplit::class.java.simpleName)

    private var header = ""
    private var footer: String? = null

    private var fileCount = 0
    private var tagCount = 0
    private var inHeader = true
    private var writer: Writer? = null
    private var cmdArgs: CommandLineArguments? = null
    private var fileOutputStream: FileOutputStream? = null

    @Throws(Exception::class)
    @JvmStatic
    fun main(args: Array<String>) {
        cmdArgs = CommandLineArguments()
        val jCommander = JCommander(cmdArgs!!)
        jCommander.parse(*args)

        if (cmdArgs!!.isHelp) {
            jCommander.usage()
            System.exit(1)
        }

        if (!cmdArgs!!.isValid) {
            System.exit(2)
        }

        val br = BufferedReader(InputStreamReader(FileInputStream(cmdArgs!!.input!!), cmdArgs!!.encoding))
        br.forEachLine { rawLine ->
            val line = rawLine.trim { it <= ' ' }
            if (line.length > 0) {

                if (inHeader && line.contains("<" + cmdArgs!!.tag)) {
                    inHeader = false
                    openNewWriter()
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
                    if (line.contains("<" + cmdArgs!!.tag)) {
                        // Start Tag
                        tagCount++
                        if (tagCount >= cmdArgs!!.count || fileOutputStream!!.channel.position() >= cmdArgs!!.size) {
                            // Maximale Grösse erreicht ==> Neue Datei eröffnen
                            openNewWriter()
                        }
                    }
                    writer!!.write(line)
                    writer!!.write("\n")
                }
            }
        }
        footer = ""
        closeWriter()
        br.close()
    }

    @Throws(IOException::class)
    private fun openNewWriter() {
        closeWriter()

        val fileName = cmdArgs!!.input
        val ext = FilenameUtils.getExtension(fileName)
        val basename = FilenameUtils.getBaseName(fileName)
        val newFileName = cmdArgs!!.output + File.separator + String.format(cmdArgs!!.format, basename, fileCount, ext)
        fileCount++

        LOGGER.info("New file: " + newFileName)
        fileOutputStream = FileOutputStream(newFileName)
        writer = OutputStreamWriter(fileOutputStream!!, cmdArgs!!.encoding)
        writer!!.write(header)
        tagCount = 0
    }

    @Throws(IOException::class)
    private fun closeWriter() {
        if (writer != null) {
            writer!!.write(footer!!)
            writer!!.close()
            writer = null
        }
    }
}
