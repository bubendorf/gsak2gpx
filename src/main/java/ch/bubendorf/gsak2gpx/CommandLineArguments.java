package ch.bubendorf.gsak2gpx;

import com.beust.jcommander.Parameter;

import java.io.File;

public class CommandLineArguments {

    // gsak2gpx --database=<PathToDB> --categories=<Kategorie> --categoryPath=<PathToCategories> --ouputPath=<OutputPath>
    // gsak2gpx -d <PathToDB> -c <Kategorie> -p <PathToCategories> -o <OutputPath>

    @Parameter(names = {"-h", "--help"}, help = true)
    private boolean help;

    @Parameter(names = {"-d", "--database"} , description = "SQLite Database File", required = false)
    private String database = "sqlite.db3";

    @Parameter(names = {"-c", "--categories"} , description = "Comma separated list of Categories", required = false)
    private String categories;

    @Parameter(names = {"-p", "--categoryPath"} , description = "Category Path", required = false)
    private String categoryPath = ".";

    @Parameter(names = {"-o", "--outputPath"} , description = "Output Path", required = false)
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

    public String getCategoryPath() {
        return categoryPath;
    }

    public void setCategoryPath(String categoryPath) {
        this.categoryPath = categoryPath;
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

    public boolean isValid() {
        if (!new File(database).exists()) {
            System.err.println("Database file '" + database + "' does not exist!");
            return false;
        }
        final File categoryPathFile = new File(categoryPath);
        if (!categoryPathFile.exists() || !categoryPathFile.isDirectory()) {
            System.err.println("Category Path '" + categoryPath + "' does not exist or is not a directory!");
            return false;
        }
        final File outputPathFile = new File(outputPath);
        if (!outputPathFile.exists() || !outputPathFile.isDirectory()) {
            System.err.println("Output Path '" + categoryPath + "' does not exist or is not a directory!");
            return false;
        }
        return true;
    }

}
