package ch.bubendorf.gsak2gpx

import freemarker.template.*
import org.slf4j.LoggerFactory
import java.sql.ResultSet
import java.sql.SQLException
import java.sql.Types
import java.text.SimpleDateFormat
import java.util.*

class ResultSetCollectionModel(private val rs: ResultSet, private val category: String) : TemplateCollectionModel {

    private var resultSetIterator: ResultSetModelIterator? = null

    @Throws(TemplateModelException::class)
    override fun iterator(): TemplateModelIterator {
        if (resultSetIterator != null) {
            throw TemplateModelException("iterator() must not be called multiple times!")
        }
        resultSetIterator = ResultSetModelIterator(rs, category)
        return resultSetIterator!!
    }

    internal class ResultSetModelIterator(val rs: ResultSet, val category: String) : TemplateModelIterator {

        private val LOGGER = LoggerFactory.getLogger(ResultSetModelIterator::class.java.simpleName)

        private var count = 0

        @Throws(TemplateModelException::class)
        override fun next(): TemplateModel {
            try {
                count++
                if (count % 1000 == 0 && category.length > 0) {
                    LOGGER.debug(category + ": " + count)
                }
                return ResultSetHashModel(rs)
            } catch (e: Exception) {
                throw TemplateModelException(e)
            }

        }

        @Throws(TemplateModelException::class)
        override fun hasNext(): Boolean {
            try {
                val hasNext = rs.next()
                if (!hasNext) {
                    rs.close()
                    if (category.length > 0 && count % 1000 != 0) {
                        LOGGER.debug(category + ": " + count)
                    }
                }
                return hasNext
            } catch (e: SQLException) {
                throw TemplateModelException(e)
            }

        }
    }

    internal class ResultSetHashModel @Throws(Exception::class)
    constructor(rs: ResultSet) : TemplateHashModel {

        private val map = HashMap<String, TemplateModel>()

        init {
            val columnCount = rs.metaData.columnCount
            for (col in 1..columnCount) {
                val columnName = rs.metaData.getColumnName(col)
                val columnType = rs.metaData.getColumnType(col)
                when (columnType) {
                    Types.INTEGER -> map.put(columnName, SimpleNumber(rs.getInt(col)))

                    Types.REAL -> map.put(columnName, SimpleNumber(rs.getDouble(col)))

                    else -> {
                        val columnValue = rs.getString(col)
                        if (columnValue != null && columnValue.length > 0) {
                            if (columnName.startsWith("has")) {
                                map.put(columnName, if (columnValue == "0") TemplateBooleanModel.FALSE else TemplateBooleanModel.TRUE)
                            } else if (columnName.contains("Date")) {
                                map.put(columnName, SimpleDate(rs.getDate(col), TemplateDateModel.DATE))
                            } else if (columnName.contains("Time")) {
                                map.put(columnName, SimpleDate(TIME_PARSER.parse(columnValue), TemplateDateModel.TIME))
                            } else {
                                map.put(columnName, SimpleScalar(columnValue.replace("[\u0000-\u0009\u000e-\u001f\u007f]".toRegex(), "")))
                            }
                        } else {
                            map.put(columnName, EMPTY_STRING)
                        }
                    }
                }
            }
        }

        @Throws(TemplateModelException::class)
        override fun get(key: String): TemplateModel {
            return map[key]!!
        }

        @Throws(TemplateModelException::class)
        override fun isEmpty(): Boolean {
            return false
        }

        companion object {

            private val EMPTY_STRING = SimpleScalar("")
            private val TIME_PARSER = SimpleDateFormat("HH:mm:ss")
        }
    }
}
