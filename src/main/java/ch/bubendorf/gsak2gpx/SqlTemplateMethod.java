package ch.bubendorf.gsak2gpx;

import freemarker.core.*;
import freemarker.template.*;
import freemarker.template.utility.DeepUnwrap;

import java.sql.*;
import java.util.List;

public class SqlTemplateMethod implements TemplateMethodModelEx {

    final Connection connection;

    public SqlTemplateMethod(Connection connection) {
        this.connection = connection;
    }

    @Override
    public Object exec(List arguments) throws TemplateModelException {
        if (arguments.size() < 1 ) {
            throw new TemplateModelException("Missing argument: sql");
        }
        String sql = arguments.get(0).toString();
        if (arguments.get(0) instanceof TemplateModel) {
            final Object unwrap = DeepUnwrap.unwrap((TemplateModel) arguments.get(0));
            sql = unwrap.toString();
        }
        String category = arguments.size() < 2 ? "" : arguments.get(1).toString();

//System.out.println(sql);

        try {
            final Statement statement = connection.createStatement();
            final ResultSet rs = statement.executeQuery(sql);

            return new ResultSetCollectionModel(rs, category);
        } catch (SQLException e) {
            // TODO
            e.printStackTrace();
        }
        return null;
    }
}
