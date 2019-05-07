package ch.bubendorf.gsak2gpx

import com.beust.jcommander.Parameter
import org.slf4j.LoggerFactory
import java.io.File
import java.util.*

class CommandLineArguments {

    private val logger = LoggerFactory.getLogger(CommandLineArguments::class.java.simpleName)

    // gsak2gpx --database=<PathToDB> --categories=<Kategorie> --categoryPath=<PathToCategories> --ouputPath=<OutputPath>
    // gsak2gpx -d <PathToDB> -c <Category> -p <PathToCategories> -o <OutputPath>

    @Parameter(names = ["-h", "--help"], help = true)
    var isHelp: Boolean = false

    @Parameter(names = ["-d", "--database"], description = "SQLite Database File[s]", required = false, variableArity = true)
    var databases: MutableList<String> = Arrays.asList("sqlite.db3")

    @Parameter(names = ["-c", "--categories"], description = "Comma separated list of Categories", required = false)
    var categories: String = ""

    @Parameter(names = ["-p", "--categoryPath"], description = "Category Paths", variableArity = true, required = false)
    var categoryPaths: MutableList<String> = Arrays.asList(".", "./include")

    @Parameter(names = ["-m", "--param"], description = "List of key value pairs (key=value)", variableArity = true, required = false)
    var params = ArrayList<String>()

    @Parameter(names = ["-o", "--outputPath"], description = "Output Path. Use - to write to stdout", required = false)
    var outputPath = "."

    @Parameter(names = ["-a", "--filename"], description = "basename of the generated file", required = false)
    var filename = ""

    @Parameter(names = ["-x", "--extension"], description = "Extension of the generated files", required = false)
    var extension = ".gpx"

    @Parameter(names = ["-b", "--append"], description = "Append to Output Path rather than overwrite", required = false)
    var append = false

    @Parameter(names = ["-f", "--outputFormat"], description = "Output format to use (XML, html, json, etc.)", required = false)
    var outputFormat = "XML"

    @Parameter(names = ["-s", "--suffix"], description = "Suffix of the generated files", required = false)
    var suffix = ""

    @Parameter(names = ["-n", "--tasks"], description = "Number of parallel tasks", required = false)
    var tasks = -1

    @Parameter(names = ["-e", "--encoding"], description = "Encoding to use", required = false)
    var encoding = "utf-8"

    val categoryList: List<String>
        get() = if (categories.isNotEmpty()) {
            ArrayList(Arrays.asList(*categories.split(",".toRegex()).dropLastWhile { it.isEmpty() }.toTypedArray()))
        } else emptyList()

    // "-" means stdout. In that case only one category is allowed
    val isValid: Boolean
        get() {
            databases.forEach { database ->
                if (!File(database).exists()) {
                    logger.error("Database file '$database' does not exist!")
                    return false
                }
            }

            for (categoryPath in categoryPaths) {
                val categoryPathFile = File(categoryPath)
                if (!categoryPathFile.exists() || !categoryPathFile.isDirectory) {
                    logger.error("Category Path '$categoryPath' does not exist or is not a directory!")
                    return false
                }
            }

            if ("-" == outputPath) {
                if (categoryList.size > 1) {
                    logger.error("Multiple categories are not allowed if outputPath is '-'.")
                    return false
                }
                if (filename.isNotEmpty()) {
                    logger.error("A filename is not allowed if outputPath is '-'.")
                    return false
                }
            } else {
                val outputPathFile = File(outputPath)
                if (!outputPathFile.exists() || !outputPathFile.isDirectory) {
                    logger.error("Output Path '$outputPath' does not exist or is not a directory!")
                    return false
                }
            }
            return true
        }

}
