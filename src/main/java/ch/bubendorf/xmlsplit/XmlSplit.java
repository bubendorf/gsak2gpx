package ch.bubendorf.xmlsplit;

import com.beust.jcommander.JCommander;
import org.apache.commons.io.FilenameUtils;

import java.io.*;


public class XmlSplit {

    private static String header = "";
    private static String footer = "</gpx>";

    private static int fileCount = 0;
    private static int fileSize = 0;
    private static int tagCount = 0;
    private static boolean inHeader = true;
    private static Writer writer = null;
private static CommandLineArguments cmdArgs;

    public static void main(String[] args) throws Exception {
        cmdArgs = new CommandLineArguments();
        new JCommander(cmdArgs).parse(args);

        if (cmdArgs.isHelp()) {
            System.out.println("Usage: java -jar xmlsplit.jar ...");
            System.exit(1);
        }

        if (!cmdArgs.isValid()) {
            System.exit(2);
        }

        BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(cmdArgs.getInput()), cmdArgs.getEncoding()));
        for (String line; (line = br.readLine()) != null; ) {
            line = line.trim();
            if (line.length() == 0) {
                continue;
            }
            if (inHeader && line.contains("<" + cmdArgs.getTag())) {
                inHeader = false;
                openNewWriter();
            }
            if (inHeader) {
                header = header + line + "\n";
            } else {
                if (line.contains("<" + cmdArgs.getTag())) {
                    // Start Tag
                    tagCount++;
                    if (tagCount >= cmdArgs.getCount() || fileSize >= cmdArgs.getSize()) {
                        // Maximale Grösse erreicht ==> Neue Datei eröffnen
                        openNewWriter();
                    }
                }
                writer.write(line);
                writer.write("\n");
                fileSize += line.length() + 2;
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

        System.out.println(newFileName);
        final FileOutputStream fileOutputStream = new FileOutputStream(newFileName);
        writer = new OutputStreamWriter(fileOutputStream, cmdArgs.getEncoding());
        writer.write(header);
        tagCount =0;
        fileSize = header.length();
    }

    private static void closeWriter() throws IOException {
        if (writer != null) {
            writer.write(footer);
            writer.close();
            writer = null;
        }
    }


}
