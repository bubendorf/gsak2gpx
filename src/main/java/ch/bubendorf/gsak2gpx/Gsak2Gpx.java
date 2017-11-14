package ch.bubendorf.gsak2gpx;

import com.beust.jcommander.JCommander;

import java.util.List;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.stream.Collectors;

public class Gsak2Gpx {

    public static void main(String[] args) throws Exception {
        CommandLineArguments cmdArgs = new CommandLineArguments();
        final JCommander jCommander = new JCommander(cmdArgs);
        jCommander.parse(args);

        if (cmdArgs.isHelp()) {
            jCommander.usage();
            System.exit(1);
        }

        if (!cmdArgs.isValid()) {
            System.exit(2);
        }

        List<String> categories = cmdArgs.getCategoryList();
        final List<Callable<SqlToGpx>> tasks = categories.stream()
                .map(category -> {
                    Callable<SqlToGpx> callableTask = () -> {
                        SqlToGpx sqlToGpx = new SqlToGpx(cmdArgs.getDatabase(), cmdArgs.getCategoryPaths(),
                                category, cmdArgs.getOutputPath(), cmdArgs.getEncoding());
                        sqlToGpx.doit();
                        return sqlToGpx;
                    };
            return callableTask;
        }).collect(Collectors.toList());

        int numberOfTasks = cmdArgs.getTasks();
        if (numberOfTasks <= 0) {
            numberOfTasks = Runtime.getRuntime().availableProcessors();
        }

        ExecutorService executorService = Executors.newFixedThreadPool(numberOfTasks);
        executorService.invokeAll(tasks);
        executorService.shutdown();
    }

}
