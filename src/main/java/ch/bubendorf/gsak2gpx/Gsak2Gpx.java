package ch.bubendorf.gsak2gpx;

import com.beust.jcommander.JCommander;
import freemarker.core.Environment;
import freemarker.template.*;
import net.sf.saxon.Transform;

import javax.xml.stream.XMLOutputFactory;
import javax.xml.stream.XMLStreamException;
import javax.xml.stream.XMLStreamWriter;
import java.io.*;
import java.lang.management.ManagementFactory;
import java.lang.management.MemoryPoolMXBean;
import java.lang.management.MemoryType;
import java.nio.charset.StandardCharsets;
import java.sql.*;
import java.text.*;
import java.util.*;
import java.util.concurrent.*;
import java.util.stream.Collectors;

import static freemarker.template.Configuration.DEFAULT_INCOMPATIBLE_IMPROVEMENTS;

public class Gsak2Gpx {
private static final int MegaBytes = 10241024;

    public static void main(String[] args) throws Exception {
        CommandLineArguments commandLineArguments = new CommandLineArguments();
        new JCommander(commandLineArguments).parse(args);

        if (commandLineArguments.isHelp()) {
            System.out.println("Usage: java -jar gsak2gpx.jar ...");
            System.exit(1);
        }

        if (!commandLineArguments.isValid()) {
            System.exit(2);
        }

        List<String> categories = getCategories(commandLineArguments);
        final List<Callable<SqlToGpx>> tasks = categories.stream()
                .map(category -> {
                    Callable<SqlToGpx> callableTask = () -> {
                        SqlToGpx sqlToGpx = new SqlToGpx(commandLineArguments.getDatabase(), commandLineArguments.getCategoryPath(),
                                category, commandLineArguments.getOutputPath(), commandLineArguments.getEncoding());
                        sqlToGpx.doit();
                        return sqlToGpx;
                    };
            return callableTask;
        }).collect(Collectors.toList());

        int numberOfTasks = commandLineArguments.getTasks();
        if (numberOfTasks <= 0) {
            numberOfTasks = Runtime.getRuntime().availableProcessors();
        }

        ExecutorService executorService = Executors.newFixedThreadPool(numberOfTasks);
        List<Future<SqlToGpx>> futures = executorService.invokeAll(tasks);
        executorService.shutdown();
    }

    private static List<String> getCategories(CommandLineArguments commandLineArguments) {
        final String categories = commandLineArguments.getCategories();
        if (categories != null && categories.length() > 0) {
            return new ArrayList<>(Arrays.asList(categories.split(",")));
        }
        // TODO: Das categoryPath Verzeichnis nach Kategorien durchsuchen
        return null;
    }
}
