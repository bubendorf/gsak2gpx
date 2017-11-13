package ch.bubendorf.ggzgen;

import com.beust.jcommander.Parameter;

@SuppressWarnings({"DefaultAnnotationParam", "WeakerAccess", "unused"})
public class CommandLineArguments {

    @Parameter(names = {"-h", "--help"}, help = true)
    private boolean help;

    @Parameter(names = {"-i", "--input"}, description = "input file", required = true)
    private String input;

    @Parameter(names = {"-o", "--output"}, description = "output file", required = false)
    private String output;

    @Parameter(names = {"-c", "--count"}, description = "Split after that many tags", required = false)
    private int count = 500;

    @Parameter(names = {"-s", "--size"}, description = "Split if the file reaches that size", required = false)
    private int size = 3 * 1000 * 1000;

    @Parameter(names = {"-f", "--format"}, description = "Format for the file names", required = false)
    private String format = "%s-%03d.%s";

    @Parameter(names = {"-e", "--encoding"}, description = "Encoding to use", required = false)
    private String encoding = "utf-8";

    public boolean isHelp() {
        return help;
    }

    public void setHelp(boolean help) {
        this.help = help;
    }

    public String getInput() {
        return input;
    }

    public void setInput(String input) {
        this.input = input;
    }

    public String getOutput() {
        return output;
    }

    public void setOutput(String output) {
        this.output = output;
    }

    public int getCount() {
        return count;
    }

    public void setCount(int count) {
        this.count = count;
    }

    public int getSize() {
        return size;
    }

    public void setSize(int size) {
        this.size = size;
    }

    public String getFormat() {
        return format;
    }

    public void setFormat(String format) {
        this.format = format;
    }

    public String getEncoding() {
        return encoding;
    }

    public void setEncoding(String encoding) {
        this.encoding = encoding;
    }

    public boolean isValid() {
        return true;
    }
}
