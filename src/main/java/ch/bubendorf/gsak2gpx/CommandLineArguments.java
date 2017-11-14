package ch.bubendorf.gsak2gpx;

import com.beust.jcommander.Parameter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

@SuppressWarnings({"unused", "WeakerAccess", "DefaultAnnotationParam"})
public class CommandLineArguments {

    private final Logger LOGGER = LoggerFactory.getLogger(CommandLineArguments.class.getSimpleName());

    // gsak2gpx --database=<PathToDB> --categories=<Kategorie> --categoryPath=<PathToCategories> --ouputPath=<OutputPath>
    // gsak2gpx -d <PathToDB> -c <Kategorie> -p <PathToCategories> -o <OutputPath>

    @Parameter(names = {"-h", "--help"}, help = true)
    private boolean help;

    @Parameter(names = {"-d", "--database"} , description = "SQLite Database File", required = false)
    private String database = "sqlite.db3";

    @Parameter(names = {"-c", "--categories"} , description = "Comma separated list of Categories", required = false)
    private String categories;

    @Parameter(names = {"-p", "--categoryPath"} , description = "Category Paths", variableArity = true, required = false)
    private List<String> categoryPaths = Arrays.asList(".", "./include");

    @Parameter(names = {"-o", "--outputPath"}, description = "Output Path. Use - to write to stdout", required = false)
    private String outputPath = ".";

    @Parameter(names = {"-n", "--tasks"} , description = "Number of parallel tasks", required = false)
    private int tasks = -1;

    @Parameter(names = {"-e", "--encoding"} , description = "Encoding to use", required = false)
    private String encoding = "utf-8";

    public boolean isHelp() {
        return help;
    }

    public void setHelp(boolean help) {
        this.help = help;
    }

    public String getDatabase() {
        return database;
    }

    public void setDatabase(String database) {
        this.database = database;
    }

    public String getCategories() {
        return categories;
    }

    public void setCategories(String categories) {
        this.categories = categories;
    }

    public List<String> getCategoryPaths() {
        return categoryPaths;
    }

    public void setCategoryPaths(List<String> categoryPath) {
        this.categoryPaths = categoryPath;
    }

    public String getOutputPath() {
        return outputPath;
    }

    public void setOutputPath(String outputPath) {
        this.outputPath = outputPath;
    }

    public int getTasks() {
        return tasks;
    }

    public void setTasks(int tasks) {
        this.tasks = tasks;
    }

    public String getEncoding() {
        return encoding;
    }

    public void setEncoding(String encoding) {
        this.encoding = encoding;
    }

    public List<String> getCategoryList() {
        if (categories != null && categories.length() > 0) {
            return new ArrayList<>(Arrays.asList(categories.split(",")));
        }
        return null;
    }

    public boolean isValid() {
        if (!new File(database).exists()) {
            LOGGER.error("Database file '" + database + "' does not exist!");
            return false;
        }

        for (String categoryPath : categoryPaths) {
            final File categoryPathFile = new File(categoryPath);
            if (!categoryPathFile.exists() || !categoryPathFile.isDirectory()) {
                LOGGER.error("Category Path '" + categoryPath + "' does not exist or is not a directory!");
                return false;
            }
        }

        if ("-".equals(outputPath)) {
            // "-" means stdout. In that case only one category is allowed
            if (getCategoryList().size() > 1) {
                LOGGER.error("Multiple categories are not allowed if outputPath is set to '-'.");
                return false;
            }
        } else {
            final File outputPathFile = new File(outputPath);
            if (!outputPathFile.exists() || !outputPathFile.isDirectory()) {
                LOGGER.error("Output Path '" + outputPath + "' does not exist or is not a directory!");
                return false;
            }
        }
        return true;
    }

}
