package ch.bubendorf.gsak2gpx;

import freemarker.template.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.HashMap;
import java.util.Map;

@SuppressWarnings("WeakerAccess")
public class ResultSetCollectionModel implements TemplateCollectionModel {

    private final ResultSet rs;
    private final String category;

    private ResultSetModelIterator resultSetIterator = null;

    public ResultSetCollectionModel(ResultSet rs, String category) {
        this.rs = rs;
        this.category = category;
    }

    @Override
    public TemplateModelIterator iterator() throws TemplateModelException {
        if (resultSetIterator != null) {
            throw new TemplateModelException("iterator() must not be called multiple times!");
        }
        resultSetIterator = new ResultSetModelIterator(rs, category);
        return resultSetIterator;
    }

    static class ResultSetModelIterator implements TemplateModelIterator {

        private final Logger LOGGER = LoggerFactory.getLogger(ResultSetModelIterator.class.getSimpleName());

        private ResultSet rs = null;
        private String category = null;
        private int count  = 0;

        public ResultSetModelIterator(ResultSet rs, String category) {
            this.rs = rs;
            this.category = category;
        }

        @Override
        public TemplateModel next() throws TemplateModelException {
            try {
                count++;
                if (count % 1000 == 0 && category.length() > 0) {
                    LOGGER.debug(category + ": "  + count);
                }
                return new ResultSetHashModel(rs);
            } catch (Exception e) {
                throw new TemplateModelException(e);
            }
        }

        @Override
        public boolean hasNext() throws TemplateModelException {
            try {
                final boolean hasNext = rs.next();
                if (!hasNext) {
                    rs.close();
                    if (category.length() > 0 && count % 1000 != 0) {
                        LOGGER.debug(category + ": " + count);
                    }
                }
                return hasNext;
            } catch (SQLException e) {
                throw new TemplateModelException(e);
            }
        }
    }

static class ResultSetHashModel implements TemplateHashModel {

    private static final SimpleScalar EMPTY_STRING = new SimpleScalar("");
    private static final DateFormat TIME_PARSER = new SimpleDateFormat("HH:mm:ss");

    private final Map<String, TemplateModel> map = new HashMap<>();

    public ResultSetHashModel(ResultSet rs) throws Exception {
        final int columnCount = rs.getMetaData().getColumnCount();
        for (int col = 1; col <= columnCount; col++) {
            final String columnName = rs.getMetaData().getColumnName(col);
            final int columnType = rs.getMetaData().getColumnType(col);
            switch (columnType) {
                case Types.INTEGER:
                    map.put(columnName, new SimpleNumber(rs.getInt(col)));
                    break;

                case Types.REAL:
                    map.put(columnName, new SimpleNumber(rs.getDouble(col)));
                    break;

                default:
                    final String columnValue = rs.getString(col);
                    if (columnValue != null && columnValue.length() > 0) {
                        if (columnName.startsWith("has")){
                            map.put(columnName, columnValue.equals("0") ? TemplateBooleanModel.FALSE : TemplateBooleanModel.TRUE);
                        } else if (columnName.contains("Date")) {
                            map.put(columnName, new SimpleDate(rs.getDate(col), TemplateDateModel.DATE));
                        } else if (columnName.contains("Time")) {
                            map.put(columnName, new SimpleDate(TIME_PARSER.parse(columnValue), TemplateDateModel.TIME));
                        } else {
                                map.put(columnName, new SimpleScalar(columnValue.replaceAll("[\u0000-\u0009\u000e-\u001f\u007f]", "")));
                        }
                    } else {
                        map.put(columnName, EMPTY_STRING);
                    }
                    break;
            }
        }
    }

    @Override
    public TemplateModel get(String key) throws TemplateModelException {
        return  map.get(key);
    }

    @Override
    public boolean isEmpty() throws TemplateModelException {
        return false;
    }
}
}
