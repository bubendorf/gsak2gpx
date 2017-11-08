package ch.bubendorf.gsak2gpx;

import freemarker.ext.beans.NumberModel;
import freemarker.template.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.HashMap;
import java.util.Map;

public class ResultSetCollectionModel implements TemplateCollectionModel {

    private ResultSet rs = null;
    private String category = null;

    public ResultSetCollectionModel(ResultSet rs, String category) {
        this.rs = rs;
        this.category = category;
    }

    @Override
    public TemplateModelIterator iterator() throws TemplateModelException {
        // Exception schmeissen falls die Methode zwei Mal aufgerufen wird!
        try {
            return new ResultSetModelIterator(rs, category);
        } catch (SQLException exp) {
          throw new TemplateModelException(exp);
        }
    }

    static class ResultSetModelIterator implements TemplateModelIterator {

        private final Logger LOGGER = LoggerFactory.getLogger(ResultSetModelIterator.class.getSimpleName());

        private ResultSet rs = null;
        private String category = null;
        private int count  = 0;

        public ResultSetModelIterator(ResultSet rs, String category) throws SQLException {
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
            } catch (SQLException e) {
                throw new TemplateModelException(e);
            }
        }

        @Override
        public boolean hasNext() throws TemplateModelException {
            try {
                final boolean hasNext = rs.next();
                if (!hasNext && category.length() > 0) {
                    LOGGER.debug(category + ": "  + count);
                }
                return hasNext;
            } catch (SQLException e) {
                throw new TemplateModelException(e);
            }
        }
    }

static class ResultSetHashModel implements TemplateHashModel {

    Map<String, Object> map = new HashMap<>();

    public ResultSetHashModel(ResultSet rs) throws SQLException {
        final int columnCount = rs.getMetaData().getColumnCount();
        for (int col = 1; col <= columnCount; col++) {
            final String columnName = rs.getMetaData().getColumnName(col);
            final int columnType = rs.getMetaData().getColumnType(col);
            switch (columnType) {
                case Types.INTEGER:
                    map.put(columnName, rs.getInt(col));
                    break;

                case Types.REAL:
                    map.put(columnName, rs.getDouble(col));
                    break;

                default:
                    final String columnValue = rs.getString(col);
                    if (columnValue != null && columnValue.length() > 0) {
                        map.put(columnName, columnValue.replaceAll("[\u0000-\u0009\u000e-\u001f\u007f]", ""));
                    } else {
                        map.put(columnName, "");
                    }
                    break;
            }
        }
    }

    @Override
    public TemplateModel get(String key) throws TemplateModelException {
        final Object value = map.get(key);
        if (value instanceof  Number) {
            return new SimpleNumber((Number)value);
        }

        return SimpleScalar.newInstanceOrNull (value == null ? "" : value.toString());
    }

    @Override
    public boolean isEmpty() throws TemplateModelException {
        return false;
    }
}
}
