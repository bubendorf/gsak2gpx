package ch.bubendorf.ggzgen;

import com.beust.jcommander.JCommander;
import org.apache.commons.io.FilenameUtils;
import org.apache.commons.io.output.CountingOutputStream;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.*;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.zip.*;

public class GGZGen {

    private static final Logger LOGGER = LoggerFactory.getLogger(GGZGen.class.getSimpleName());

    private static String header = "";
    private static String footer = null;

    private static int tagCount = 0;
    private static int totalCacheCount = 0;
    private static boolean inHeader = true;
    private static Writer writer = null;
    private static CommandLineArguments cmdArgs;

    private static ZipOutputStream zipStream;
    private static CountingOutputStream zipCountingStream;
    private static int lastEntryZipStreamPosition = 0;
    private static CheckedOutputStream checkedStream;
    private static CountingOutputStream entryCountingStream;
    private static ZipEntry zipEntry;

    private static FileIndex fileIndex;
    private static List<FileIndex> fileIndices = new ArrayList<>();
    private static CacheIndex cacheIndex;

    private static Pattern CACHE_CODE_PATTERN = Pattern.compile("<name>(\\w*)</name>");
    private static Pattern CACHE_NAME_PATTERN = Pattern.compile("<desc>(.*)</desc>");
    private static Pattern CACHE_TYPE_PATTERN = Pattern.compile("<type>Geocache.(.+)</type>");
    private static Pattern CACHE_LAT_PATTERN = Pattern.compile("wpt.*lat=\"([0-9.]*)\"");
    private static Pattern CACHE_LON_PATTERN = Pattern.compile("wpt.*lon=\"([0-9.]*)\"");
    private static Pattern CACHE_DIFFICULTY_PATTERN = Pattern.compile("<groundspeak:difficulty>([0-9.]*)</groundspeak:difficulty>");
    private static Pattern CACHE_SIZE_PATTERN = Pattern.compile("<groundspeak:container>(\\w*)</groundspeak:container>");
    private static Pattern CACHE_TERRAIN_PATTERN = Pattern.compile("<groundspeak:terrain>([0-9.]*)</groundspeak:terrain>");

    private static Pattern CACHE_WAYPOINT_PATTERN = Pattern.compile("^\\s*<\\s*wpt\\W.*$");

    private static Map<String, Integer> CONATINER_SIZE_MAP = new HashMap<>();

    static {
        CONATINER_SIZE_MAP.put("micro", 2);
        CONATINER_SIZE_MAP.put("small", 3);
        CONATINER_SIZE_MAP.put("regular", 4);
        CONATINER_SIZE_MAP.put("large", 5);
        CONATINER_SIZE_MAP.put("other", -1);
        CONATINER_SIZE_MAP.put("not chosen", -2);
        CONATINER_SIZE_MAP.put("virtual", 0);
    }

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

        BufferedReader reader;
        if ("-".equals(cmdArgs.getInput())) {
            reader = new BufferedReader(new InputStreamReader(System.in, cmdArgs.getEncoding()));
        } else {
            reader = new BufferedReader(new InputStreamReader(new FileInputStream(cmdArgs.getInput()), cmdArgs.getEncoding()), 65536);
        }
        for (String line; (line = reader.readLine()) != null; ) {
            line = line.trim();
            if (line.length() == 0) {
                // Leerzeilen ignorieren
                continue;
            }

            if (inHeader && CACHE_WAYPOINT_PATTERN.matcher(line).matches()) {
                inHeader = false;
                openZipFile();
                openZipEntry();
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
                if (CACHE_WAYPOINT_PATTERN.matcher(line).matches()) {
                    // Start Tag
                    tagCount++;
                    nextCacheIndex();
                    if (tagCount >= cmdArgs.getCount() || entryCountingStream.getCount() >= cmdArgs.getSize()) {
                        // Maximale Grösse erreicht ==> Neue Datei eröffnen
                        openZipEntry();
                    }
                    totalCacheCount++;
                }

                final Matcher codeMatcher = CACHE_CODE_PATTERN.matcher(line);
                if (codeMatcher.find()) {
                    cacheIndex.setCode(codeMatcher.group(1));
                }
                final Matcher nameMatcher = CACHE_NAME_PATTERN.matcher(line);
                if (nameMatcher.find()) {
                    cacheIndex.setName(nameMatcher.group(1));
                }
                final Matcher typeMatcher = CACHE_TYPE_PATTERN.matcher(line);
                if (typeMatcher.find()) {
                    cacheIndex.setType(typeMatcher.group(1));
                }
                final Matcher latMatcher = CACHE_LAT_PATTERN.matcher(line);
                if (latMatcher.find()) {
                    cacheIndex.setLat(Double.parseDouble(latMatcher.group(1)));
                }
                final Matcher lonMatcher = CACHE_LON_PATTERN.matcher(line);
                if (lonMatcher.find()) {
                    cacheIndex.setLon(Double.parseDouble(lonMatcher.group(1)));
                }
                final Matcher diffMatcher = CACHE_DIFFICULTY_PATTERN.matcher(line);
                if (diffMatcher.find()) {
                    cacheIndex.setDifficulty(Double.parseDouble(diffMatcher.group(1)));
                }
                final Matcher terrMatcher = CACHE_TERRAIN_PATTERN.matcher(line);
                if (terrMatcher.find()) {
                    cacheIndex.setTerrain(Double.parseDouble(terrMatcher.group(1)));
                }
                final Matcher sizeMatcher = CACHE_SIZE_PATTERN.matcher(line);
                if (sizeMatcher.find()) {
                    cacheIndex.setSize(CONATINER_SIZE_MAP.get(sizeMatcher.group(1).toLowerCase()));
                }

                writer.write(line);
                writer.write("\n");
            }
        }
        footer = "";
        nextCacheIndex();
        closeZipEntry();
        reader.close();
        closeZipFile();
    }

    private static void nextCacheIndex() throws IOException {
        writer.flush();
        if (cacheIndex != null) {
            cacheIndex.setAwesomeness(3.0);
            cacheIndex.setFile_len(entryCountingStream.getCount() - cacheIndex.getFile_pos());
            fileIndex.addCacheIndex(cacheIndex);
        }
        cacheIndex = new CacheIndex();
        cacheIndex.setFile_pos(entryCountingStream.getCount());
    }

    private static void openZipFile() throws FileNotFoundException {
        final FileOutputStream fileOutputStream = new FileOutputStream(cmdArgs.getOutput());
        BufferedOutputStream bufferedStream = new BufferedOutputStream(fileOutputStream, 65536);
        zipCountingStream = new CountingOutputStream(bufferedStream);
        zipStream = new ZipOutputStream(zipCountingStream);
        zipStream.setLevel(9);
        zipStream.setComment("ggzgen by Markus Bubendorf");
    }

    private static void closeZipFile() throws IOException {
        zipEntry = new ZipEntry("index/com/garmin/geocaches/v0/index.xml");
        zipStream.putNextEntry(zipEntry);
        writer = new OutputStreamWriter(zipStream, cmdArgs.getEncoding());
        final String indexFile = getIndexFile();
        writer.write(indexFile);
        writer.flush();
        zipStream.closeEntry();
        zipStream.close();
    }

    private static String getIndexFile() {
        final StringBuilder sb = new StringBuilder(8192);
        sb.append("<ggz>\n");
        for (FileIndex fileIndex : fileIndices) {
            sb.append(fileIndex.toXML());
        }
        sb.append("</ggz>\n");
        return sb.toString();
    }

    private static void openZipEntry() throws IOException {
        closeZipEntry();

        String fileName = "-".equals(cmdArgs.getInput()) ? "stdin.gpx" : cmdArgs.getInput();
        String ext = FilenameUtils.getExtension(fileName);
        String basename = FilenameUtils.getBaseName(fileName);
        String newFileName = String.format(cmdArgs.getFormat(), basename, fileIndices.size(), ext);

        LOGGER.debug("New file: " + newFileName);
        zipEntry = new ZipEntry("data/" + newFileName);
        zipStream.putNextEntry(zipEntry);

        fileIndex = new FileIndex();
        fileIndex.setName(newFileName);
        fileIndices.add(fileIndex);

        entryCountingStream = new CountingOutputStream(zipStream);
        checkedStream = new CheckedOutputStream(entryCountingStream, new CRC32());
        writer = new OutputStreamWriter(checkedStream, cmdArgs.getEncoding());
        writer.write(header);
        tagCount = 0;
    }

    private static void closeZipEntry() throws IOException {
        if (writer != null) {
            writer.write(footer);
            writer.flush();
            checkedStream.flush();
            fileIndex.setCrc(Long.toHexString(checkedStream.getChecksum().getValue()));
            writer = null;
            zipStream.closeEntry();
            zipEntry = null;

            NumberFormat oneDigitNumberFormat = new DecimalFormat("0.0");
            int currentZipStreamPosition = zipCountingStream.getCount();
            int zipSizeOfEntry = currentZipStreamPosition - lastEntryZipStreamPosition;
            LOGGER.info(fileIndex.getName() + ": " +
                    "Count=" + fileIndex.getCacheIndexSize() +
                    ", Total=" + totalCacheCount +
                    ", Filesize=" + entryCountingStream.getCount() +
                    ", OnDisk=" + zipSizeOfEntry + " (" + oneDigitNumberFormat.format(100.0 / entryCountingStream.getCount() * zipSizeOfEntry) + "%)");
            lastEntryZipStreamPosition = currentZipStreamPosition;
        }
    }
}
