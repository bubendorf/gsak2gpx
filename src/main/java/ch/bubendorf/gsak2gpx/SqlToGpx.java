package ch.bubendorf.gsak2gpx;

import freemarker.cache.FileTemplateLoader;
import freemarker.cache.MultiTemplateLoader;
import freemarker.core.Environment;
import freemarker.core.XMLOutputFormat;
import freemarker.template.Configuration;
import freemarker.template.Template;
import freemarker.template.TemplateExceptionHandler;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.sqlite.Function;
import org.sqlite.SQLiteConfig;

import java.io.*;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static freemarker.template.Configuration.DEFAULT_INCOMPATIBLE_IMPROVEMENTS;

@SuppressWarnings("WeakerAccess")
public class SqlToGpx {

    private final Logger LOGGER = LoggerFactory.getLogger(SqlToGpx.class.getSimpleName());

    private final String database;
    private final List<String> categoryPaths;
    private final String category;
    private final String outputPath;
    private String encoding;

    public SqlToGpx(String database, List<String> categoryPaths, String category, String outputPath, String encoding) {
        this.database = database;
        this.categoryPaths = categoryPaths;
        this.category = category;
        this.outputPath = outputPath;
        this.encoding = encoding;
    }

    public void doit() {
        try {
            LOGGER.info("Start with " + category);
            Class.forName("org.sqlite.JDBC");
            LOGGER.debug("Open " + database);

            SQLiteConfig config = new SQLiteConfig();
            config.setReadOnly(true);
            config.setSharedCache(true);
            config.enableLoadExtension(true);
            config.setDateStringFormat("yyyy-MM-dd");
            Connection connection = DriverManager.getConnection("jdbc:sqlite:" + database, config.toProperties());
            Function.create(connection, "sqrt", new Function() {
            protected void xFunc() throws SQLException {
                    result(Math.sqrt(value_double(0)));
                }
            });
            Function.create(connection, "toUtf8", new Function() {
                protected void xFunc() throws SQLException {
                    try {
                        final byte[] bytes = value_blob(0);
                        String text = new String(bytes, 0, bytes.length, "iso8859-1");
                        result(text);
                    } catch (UnsupportedEncodingException e) {
                        throw new SQLException(e);
                    }
                    }
            });

            SqlTemplateMethod sqlTemplateMethod = new SqlTemplateMethod(connection);
            Configuration cfg = new Configuration(DEFAULT_INCOMPATIBLE_IMPROVEMENTS);

            final FileTemplateLoader[] fileTemplateLoaders = categoryPaths.stream().map(cat -> {
                try {
                    return new FileTemplateLoader(new File(cat));
                } catch (IOException e) {
                    throw new RuntimeException(e);
                }
            }).toArray(FileTemplateLoader[]::new);

            MultiTemplateLoader mtl = new MultiTemplateLoader(fileTemplateLoaders);
            cfg.setTemplateLoader(mtl);
//            cfg.setDirectoryForTemplateLoading(new File(categoryPath));
            cfg.setDefaultEncoding("UTF-8");
            cfg.setTemplateExceptionHandler(TemplateExceptionHandler.RETHROW_HANDLER);
            cfg.setLogTemplateExceptions(false);
            cfg.setOutputFormat(XMLOutputFormat.INSTANCE);

            Map<String, Object> rootModel = new HashMap<>();
            rootModel.put("sql", sqlTemplateMethod);
            rootModel.put("category", category);
            rootModel.put("encoding", encoding);
            rootModel.put("date", LocalDate.now());
            rootModel.put("time", LocalTime.now());
            rootModel.put("datetime", LocalDateTime.now());

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
