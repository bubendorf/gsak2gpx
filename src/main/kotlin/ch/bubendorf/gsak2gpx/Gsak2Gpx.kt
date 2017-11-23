package ch.bubendorf.gsak2gpx

import com.beust.jcommander.JCommander
import java.util.concurrent.Callable
import java.util.concurrent.Executors

fun main(args: Array<String>) {
    Gsak2Gpx().gsak2gpx(args)
}

class Gsak2Gpx {

    //    @Throws(Exception::class)
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

        val tasks = categories.map { category ->
            Callable {
                SqlToGpx(cmdArgs.database, cmdArgs.categoryPaths, category, cmdArgs.outputPath, cmdArgs.encoding).doit()
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