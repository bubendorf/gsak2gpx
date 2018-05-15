package ch.bubendorf.ggzgen

import com.beust.jcommander.Parameter
import org.slf4j.LoggerFactory

import java.io.File

class CommandLineArguments {

    private val LOGGER = LoggerFactory.getLogger(CommandLineArguments::class.java.simpleName)

    @Parameter(names = arrayOf("-h", "--help"), help = true)
    var isHelp: Boolean = false

    @Parameter(names = arrayOf("-i", "--input"), description = "input file. Use '-' to read from stdin.", required = true)
    var input: String = ""

    @Parameter(names = arrayOf("-a", "--name"), description = "name of the internal files", required = false)
    var name = ""

    @Parameter(names = arrayOf("-o", "--output"), description = "output file", required = false)
    var output: String? = null

    @Parameter(names = arrayOf("-c", "--count"), description = "Split after that many tags/geocaches", required = false)
    var count = 500

    @Parameter(names = arrayOf("-s", "--size"), description = "Split if the file exceeds that size", required = false)
    var size = 3 * 1000 * 1000

    @Parameter(names = arrayOf("-f", "--format"), description = "Format for the file names", required = false)
    var format = "%s-%03d.%s"

    @Parameter(names = arrayOf("-e", "--encoding"), description = "Encoding to use", required = false)
    var encoding = "utf-8"

    val isValid: Boolean
        get() {
            if ("-" != input && !File(input).exists()) {
                LOGGER.error("Input file '$input' does not exist!")
                return false
            }
            if (output.isNullOrBlank()) {
                LOGGER.error("Output must not be empty")
                return false
            }

            return true
        }
}
