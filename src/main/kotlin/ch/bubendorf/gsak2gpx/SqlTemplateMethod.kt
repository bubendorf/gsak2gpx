package ch.bubendorf.gsak2gpx

import freemarker.template.TemplateMethodModelEx
import freemarker.template.TemplateModel
import freemarker.template.TemplateModelException
import freemarker.template.utility.DeepUnwrap
import org.slf4j.LoggerFactory
import java.sql.Connection
import java.sql.SQLException

class SqlTemplateMethod(private val connection: Connection) : TemplateMethodModelEx {

    private val LOGGER = LoggerFactory.getLogger(SqlTemplateMethod::class.java.simpleName)

    @Throws(TemplateModelException::class)
    override fun exec(arguments: List<*>): Any {
        if (arguments.size < 1) {
            throw TemplateModelException("Missing argument: sql")
        }
        var sql = arguments[0].toString()
        if (arguments[0] is TemplateModel) {
            val unwrap = DeepUnwrap.unwrap(arguments[0] as TemplateModel)
            sql = unwrap.toString()
        }
        LOGGER.debug(sql)
        val category = if (arguments.size < 2) "" else arguments[1].toString()

        try {
            val statement = connection.createStatement()
            val rs = statement.executeQuery(sql)

            return ResultSetCollectionModel(rs, category)
        } catch (e: SQLException) {
            throw TemplateModelException(e)
        }

    }
}
