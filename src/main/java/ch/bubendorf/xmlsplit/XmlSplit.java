package ch.bubendorf.xmlsplit;

import com.beust.jcommander.JCommander;
import org.apache.commons.io.FilenameUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;


public class XmlSplit {

    private static final Logger LOGGER = LoggerFactory.getLogger(XmlSplit.class.getSimpleName());

    private static String header = "";
    private static String footer = null;

    private static int fileCount = 0;
    private static int tagCount = 0;
    private static boolean inHeader = true;
    private static Writer writer = null;
    private static CommandLineArguments cmdArgs;
    private static FileOutputStream fileOutputStream;

    public static void main(String[] args) throws Exception {
        cmdArgs = new CommandLineArguments();
        JCommander jCommander = new JCommander(cmdArgs);
        jCommander.parse(args);

        if (cmdArgs.isHelp()) {
            jCommander.usage();
            System.exit(1);
        }

        if (!cmdArgs.isValid()) {
            System.exit(2);
        }

        BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(cmdArgs.getInput()), cmdArgs.getEncoding()));
        for (String line; (line = br.readLine()) != null; ) {
            line = line.trim();
            if (line.length() == 0) {
                // Leerzeilen ignorieren
                continue;
            }

            if (inHeader && line.contains("<" + cmdArgs.getTag())) {
                inHeader = false;
                openNewWriter();
            }
            if (inHeader) {
                header = header + line + "\n";
                if (footer == null && line.startsWith("<") && !line.startsWith("<?")) {
                    // Das Root-Tag für den Footer extrahieren
                    Pattern pattern = Pattern.compile("^\\s*<\\s*(\\w*)\\W.*$");
                    Matcher matcher = pattern.matcher(line);
                    if (matcher.matches()) {
                        footer = "</" + matcher.group(1) + ">";
                    }
                }
            } else {
                if (line.contains("<" + cmdArgs.getTag())) {
                    // Start Tag
                    tagCount++;
                    if (tagCount >= cmdArgs.getCount() || fileOutputStream.getChannel().position() >= cmdArgs.getSize()) {
                        // Maximale Grösse erreicht ==> Neue Datei eröffnen
                        openNewWriter();
                    }
                }
                writer.write(line);
                writer.write("\n");
            }
        }
        footer ="";
        closeWriter();
        br.close();
    }

    private static void openNewWriter() throws IOException {
        closeWriter();

        String fileName = cmdArgs.getInput();
        String ext = FilenameUtils.getExtension(fileName);
        String basename = FilenameUtils.getBaseName(fileName);
        String newFileName = cmdArgs.getOutput() + File.separator +  String.format(cmdArgs.getFormat(),basename, fileCount, ext);
        fileCount++;

        LOGGER.info("New file: " + newFileName);
        fileOutputStream = new FileOutputStream(newFileName);
        writer = new OutputStreamWriter(fileOutputStream, cmdArgs.getEncoding());
        writer.write(header);
        tagCount =0;
    }

    private static void closeWriter() throws IOException {
        if (writer != null) {
            writer.write(footer);
            writer.close();
            writer = null;
        }
    }
}
