package ch.bubendorf.gsak2gpx

import com.beust.jcommander.JCommander
import java.util.concurrent.Callable
import java.util.concurrent.Executors

fun main(args: Array<String>) {
    Gsak2Gpx().gsak2gpx(args)
}

class Gsak2Gpx {
    fun gsak2gpx(args: Array<String>) {
        val cmdArgs = CommandLineArguments()
        val jCommander = JCommander(cmdArgs)
        jCommander.parse(*args)

        if (cmdArgs.isHelp) {
            jCommander.usage()
            System.exit(1)
        }

        if (!cmdArgs.isValid) {
            System.exit(2)
        }

        val categories = cmdArgs.categoryList
        val params = cmdArgs.params.associate {
            val split = it.split("=")
            Pair(split[0], split[1])
        }
        val tasks = categories.map { category ->
            Callable {
                SqlToGpx(cmdArgs.database, cmdArgs.categoryPaths, category, cmdArgs.outputPath,
                        if (cmdArgs.filename.length > 0) cmdArgs.filename else category,
                        cmdArgs.suffix, cmdArgs.extension, cmdArgs.encoding, cmdArgs.outputFormat, params).doit()
            }
        }.toList()

        var numberOfTasks = cmdArgs.tasks
        if (numberOfTasks <= 0) {
            numberOfTasks = Runtime.getRuntime().availableProcessors()
        }

        val executorService = Executors.newFixedThreadPool(numberOfTasks)
        executorService.invokeAll(tasks)
        executorService.shutdown()
    }
}
