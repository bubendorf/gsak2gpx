package ch.bubendorf.gsak2gpx;

import freemarker.core.Environment;
import freemarker.core.XMLOutputFormat;
import freemarker.template.Configuration;
import freemarker.template.Template;
import freemarker.template.TemplateExceptionHandler;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.*;
import java.sql.Connection;
import java.sql.DriverManager;
import java.util.HashMap;
import java.util.Map;

import static freemarker.template.Configuration.DEFAULT_INCOMPATIBLE_IMPROVEMENTS;

public class SqlToGpx {

    private final Logger LOGGER = LoggerFactory.getLogger(SqlToGpx.class.getSimpleName());

    private final String database;
    private final String categoryPath;
    private final String category;
    private final String outputPath;
    private String encoding;

    public SqlToGpx(String database, String categoryPath, String category, String outputPath, String encoding) {
        this.database = database;
        this.categoryPath = categoryPath;
        this.category = category;
        this.outputPath = outputPath;
        this.encoding = encoding;
    }

    public void doit() {
        try {
            LOGGER.info("Start with " + category);
            Class.forName("org.sqlite.JDBC");
            LOGGER.info("Open " + database);
//        Connection connection = DriverManager.getConnection("jdbc:sqlite:" + database + ";Version=3;Pooling=True;Max Pool Size=20;Read Only=True;FailIfMissing=True;");
            Connection connection = DriverManager.getConnection("jdbc:sqlite:" + database);

            SqlTemplateMethod sqlTemplateMethod = new SqlTemplateMethod(connection);
            Configuration cfg = new Configuration(DEFAULT_INCOMPATIBLE_IMPROVEMENTS);

            cfg.setDirectoryForTemplateLoading(new File(categoryPath));
            cfg.setDefaultEncoding("UTF-8");
            cfg.setTemplateExceptionHandler(TemplateExceptionHandler.RETHROW_HANDLER);
            cfg.setLogTemplateExceptions(false);
            cfg.setOutputFormat(XMLOutputFormat.INSTANCE);

            Map<String, Object> rootModel = new HashMap<>();
            rootModel.put("sql", sqlTemplateMethod);
            rootModel.put("category", category);
            rootModel.put("encoding", encoding);

            Template template = cfg.getTemplate(category + ".ftlx");
            Writer out = new OutputStreamWriter(new FileOutputStream(outputPath + "/" + category + ".gpx"), encoding);
            Environment environment = template.createProcessingEnvironment(rootModel, out);
            environment.setOutputEncoding(encoding);
            environment.process();
            out.close();

            LOGGER.info("Finished " + category);
        } catch (Exception e) {
            LOGGER.error(e.getMessage(), e);
        }
    }
}
