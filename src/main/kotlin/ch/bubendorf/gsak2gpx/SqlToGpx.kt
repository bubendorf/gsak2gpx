package ch.bubendorf.gsak2gpx

import freemarker.cache.FileTemplateLoader
import freemarker.cache.MultiTemplateLoader
import freemarker.cache.TemplateLoader
import freemarker.core.XMLOutputFormat
import freemarker.template.Configuration
import freemarker.template.Configuration.DEFAULT_INCOMPATIBLE_IMPROVEMENTS
import freemarker.template.TemplateExceptionHandler
import org.slf4j.LoggerFactory
import org.sqlite.Function
import org.sqlite.SQLiteConfig
import java.io.*
import java.nio.charset.Charset
import java.sql.DriverManager
import java.sql.SQLException
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.LocalTime

class SqlToGpx(private val database: String, private val categoryPaths: List<String>, private val category: String, private val outputPath: String, private val encoding: String) {

    private val LOGGER = LoggerFactory.getLogger(SqlToGpx::class.java.simpleName)

    fun doit() {
        try {
            LOGGER.info("Start with " + category)
            val startTime = System.currentTimeMillis()
            Class.forName("org.sqlite.JDBC")
            LOGGER.debug("Open " + database)

            val config = SQLiteConfig()
            config.setReadOnly(true)
            config.setSharedCache(true)
            config.enableLoadExtension(true)
            config.setDateStringFormat("yyyy-MM-dd")
            config.setCacheSize(65536)
            val connection = DriverManager.getConnection("jdbc:sqlite:" + database, config.toProperties())
            Function.create(connection, "sqrt", object : Function() {
                @Throws(SQLException::class)
                override fun xFunc() {
                    result(Math.sqrt(value_double(0)))
                }
            })
            Function.create(connection, "toUtf8", object : Function() {
                @Throws(SQLException::class)
                override fun xFunc() {
                    try {
                        val bytes = value_blob(0)
                        val text = String(bytes, 0, bytes.size, Charset.forName("iso8859-1"))
                        result(text)
                    } catch (e: UnsupportedEncodingException) {
                        throw SQLException(e)
                    }

                }
            })
            Function.create(connection, "oneChar", object : Function() {
                @Throws(SQLException::class)
                override fun xFunc() {
                    try {
                        val value = value_double(0)
                        if (value - Math.floor(value) > 0.2) {
                            // Keine Ganzzahl ==> Buchstabe A-Z draus machen
                            result("" + ('A' + Math.floor(value).toInt()))
                        } else {
                            // Eine Ganzzahl ==> So zurück geben, aber als Buchstabe
                            result("" + ('0' + value.toInt()))
                        }
                    } catch (e: Exception) {
                        throw SQLException(e)
                    }
                }
            })

            val sqlTemplateMethod = SqlTemplateMethod(connection)
            val cfg = Configuration(DEFAULT_INCOMPATIBLE_IMPROVEMENTS)

            val fileTemplateLoaders = categoryPaths.map { cat ->
                FileTemplateLoader(File(cat))
            }.toTypedArray()

            val mtl = MultiTemplateLoader(fileTemplateLoaders as Array<out TemplateLoader>?)
            cfg.templateLoader = mtl
            cfg.defaultEncoding = encoding
            cfg.templateExceptionHandler = TemplateExceptionHandler.RETHROW_HANDLER
            cfg.logTemplateExceptions = false
            cfg.outputFormat = XMLOutputFormat.INSTANCE

            val rootModel = hashMapOf(
            "sql" to sqlTemplateMethod,
            "category" to category,
            "encoding" to encoding,
            "date" to LocalDate.now(),
            "time" to LocalTime.now(),
            "datetime" to LocalDateTime.now())

            val template = cfg.getTemplate(category + ".ftlx")
            val out = if ("-" == outputPath) {
                OutputStreamWriter(System.out, encoding)
            } else {
                OutputStreamWriter(FileOutputStream("$outputPath/$category.gpx"), encoding)
            }
            val environment = template.createProcessingEnvironment(rootModel, out)
            environment.outputEncoding = encoding
            environment.process()
            out.close()

            val duration = System.currentTimeMillis() - startTime
            LOGGER.info("Finished " + category + " after " + duration + "ms")
        } catch (e: Exception) {
            LOGGER.error(e.message, e)
        }

    }
}
