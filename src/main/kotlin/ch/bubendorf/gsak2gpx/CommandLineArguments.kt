package ch.bubendorf.gsak2gpx

import com.beust.jcommander.Parameter
import org.slf4j.LoggerFactory
import java.io.File
import java.util.*

class CommandLineArguments {

    private val LOGGER = LoggerFactory.getLogger(CommandLineArguments::class.java.simpleName)

    // gsak2gpx --database=<PathToDB> --categories=<Kategorie> --categoryPath=<PathToCategories> --ouputPath=<OutputPath>
    // gsak2gpx -d <PathToDB> -c <Kategorie> -p <PathToCategories> -o <OutputPath>

    @Parameter(names = arrayOf("-h", "--help"), help = true)
    var isHelp: Boolean = false

    @Parameter(names = arrayOf("-d", "--database"), description = "SQLite Database File", required = false)
    var database = "sqlite.db3"

    @Parameter(names = arrayOf("-c", "--categories"), description = "Comma separated list of Categories", required = false)
    var categories: String? = null

    @Parameter(names = arrayOf("-p", "--categoryPath"), description = "Category Paths", variableArity = true, required = false)
    var categoryPaths = Arrays.asList(".", "./include")

    @Parameter(names = arrayOf("-o", "--outputPath"), description = "Output Path. Use - to write to stdout", required = false)
    var outputPath = "."

    @Parameter(names = arrayOf("-n", "--tasks"), description = "Number of parallel tasks", required = false)
    var tasks = -1

    @Parameter(names = arrayOf("-e", "--encoding"), description = "Encoding to use", required = false)
    var encoding = "utf-8"

    val categoryList: List<String>
        get() = if (categories != null && categories!!.length > 0) {
            ArrayList(Arrays.asList(*categories!!.split(",".toRegex()).dropLastWhile { it.isEmpty() }.toTypedArray()))
        } else emptyList()

    // "-" means stdout. In that case only one category is allowed
    val isValid: Boolean
        get() {
            if (!File(database).exists()) {
                LOGGER.error("Database file '$database' does not exist!")
                return false
            }

            for (categoryPath in categoryPaths) {
                val categoryPathFile = File(categoryPath)
                if (!categoryPathFile.exists() || !categoryPathFile.isDirectory) {
                    LOGGER.error("Category Path '$categoryPath' does not exist or is not a directory!")
                    return false
                }
            }

            if ("-" == outputPath) {
                if (categoryList!!.size > 1) {
                    LOGGER.error("Multiple categories are not allowed if outputPath is set to '-'.")
                    return false
                }
            } else {
                val outputPathFile = File(outputPath)
                if (!outputPathFile.exists() || !outputPathFile.isDirectory) {
                    LOGGER.error("Output Path '$outputPath' does not exist or is not a directory!")
                    return false
                }
            }
            return true
        }

}