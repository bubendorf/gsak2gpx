package ch.bubendorf.xmlsplit

import com.beust.jcommander.Parameter

class CommandLineArguments {

    @Parameter(names = arrayOf("-h", "--help"), help = true)
    var isHelp: Boolean = false

    @Parameter(names = arrayOf("-i", "--input"), description = "input file", required = true)
    var input: String? = null

    @Parameter(names = arrayOf("-o", "--output"), description = "output path", required = true)
    var output: String? = null

    @Parameter(names = arrayOf("-t", "--tag"), description = "tag/element to split at", required = false)
    var tag = "wpt"

    @Parameter(names = arrayOf("-c", "--count"), description = "Split after that many tags", required = false)
    var count = 1000

    @Parameter(names = arrayOf("-s", "--size"), description = "Split if the file reaches that size", required = false)
    var size = 5 * 1024 * 1024

    @Parameter(names = arrayOf("-f", "--format"), description = "Format for the file names", required = false)
    var format = "%s-%03d.%s"

    @Parameter(names = arrayOf("-e", "--encoding"), description = "Encoding to use", required = false)
    var encoding = "utf-8"

    // TODO: Check for valid input file
    val isValid: Boolean
        get() = true
}
