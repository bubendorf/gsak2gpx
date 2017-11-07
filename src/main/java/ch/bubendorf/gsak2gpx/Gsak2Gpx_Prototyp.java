package ch.bubendorf.gsak2gpx;

import freemarker.core.Environment;
import freemarker.template.*;
import net.sf.saxon.Transform;

import javax.xml.stream.XMLOutputFactory;
import javax.xml.stream.XMLStreamException;
import javax.xml.stream.XMLStreamWriter;
import java.io.*;
import java.lang.management.ManagementFactory;
import java.lang.management.MemoryPoolMXBean;
import java.lang.management.MemoryType;
import java.nio.charset.StandardCharsets;
import java.sql.*;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.*;

import static freemarker.template.Configuration.DEFAULT_INCOMPATIBLE_IMPROVEMENTS;

public class Gsak2Gpx_Prototyp {
private static final int MegaBytes = 10241024;

    public static void main(String[] args) throws Exception {
        final List<Map<String, Object>> dataModel = readIntoMemory(args[0]);
        transformToGpx(args[0], dataModel);

//        exportToXML(args[0]);
//        transformToGpx(args[0]);
    }

    private static void transformToGpx(String category, List<Map<String,Object>> dataModel) throws IOException, TemplateException {
        // Create your Configuration instance, and specify if up to what FreeMarker
        // version (here 2.3.27) do you want to apply the fixes that are not 100%
        // backward-compatible. See the Configuration JavaDoc for details.
        Configuration cfg = new Configuration(DEFAULT_INCOMPATIBLE_IMPROVEMENTS);

        // Specify the source where the template files come from. Here I set a
        // plain directory for it, but non-file-system sources are possible too:
        //cfg.setDirectoryForTemplateLoading(new File("/where/you/store/templates"));

        // Set the preferred charset template files are stored in. UTF-8 is
        // a good choice in most applications:
        cfg.setDefaultEncoding("UTF-8");

        // Sets how errors will appear.
        cfg.setTemplateExceptionHandler(TemplateExceptionHandler.RETHROW_HANDLER);

        // Don't log exceptions inside FreeMarker that it will thrown at you anyway:
        cfg.setLogTemplateExceptions(false);

        // Wrap unchecked exceptions thrown during template processing into TemplateException-s.
        //cfg.setWrapUncheckedExceptions(true);

        long startTime = System.currentTimeMillis();
        Map<String, Object> rootModel = new HashMap<>();
        rootModel.put("wpts", dataModel);
        rootModel.put("category", category);

        Template template = cfg.getTemplate("CacheToCache.ftlx");
        Writer out = new OutputStreamWriter(new FileOutputStream(category + ".gpx"), StandardCharsets.ISO_8859_1);
        Environment environment = template.createProcessingEnvironment(rootModel, out);
        environment.setOutputEncoding(StandardCharsets.ISO_8859_1.name());
        environment.process();
        out.close();

        long duration = System.currentTimeMillis() - startTime;
        System.out.println("Convert to GPX: " + category + ". Aus die Maus!");
        System.out.println("Zeitbedarf: " + duration + "ms");
//        showMemory();
//        NumberFormat nf = new DecimalFormat("0.0");
//        System.out.println("pro Cache: " + nf.format (duration / (double)count) + "ms");
    }

    private static List<Map<String, Object>> readIntoMemory(final String category) throws Exception {
        Class.forName("org.sqlite.JDBC");
        Connection connection = DriverManager.getConnection("jdbc:sqlite:" + "/Users/mbu/ExtDisk/Geo/GSAK8/data/Default/sqlite.db3");
        long startTime = System.currentTimeMillis();
        final Statement statement = connection.createStatement();
        final String sql = "select ca.Code, ca.Name, ca.SmartName, ca.Latitude, ca.Longitude, ca.CacheType, ca.Elevation, " +
                "ca.Difficulty, ca.Terrain, ca.PlacedBy, ca.PlacedDate, ca.LastFoundDate, cu.GefundenVon, " +
                "ca.Guid, ca.CacheId, ca.OwnerId, ca.OwnerName, ca.Container, ca.Country, ca.State, cm.LongDescription, cm.ShortDescription, " +
                "ca.ShortHtm, ca.LongHtm, cm.Hints, " +
                "group_concat(at.aId || '-' || at.aInc) as Attributes " +
                " from Caches ca " +
                " join Custom cu on ca.code = cu.cCode " +
                " join CacheMemo cm on ca.code=cm.Code " +
                " left join Attributes at on ca.Code = at.aCode " +
                " where 1=1 " +
                " and ca.UserFlag=1 " +
                " group by ca.Code " +
                " limit 200";
        final ResultSet rs = statement.executeQuery(sql);

        List<Map<String, Object>> waypoints = new ArrayList<>();

        int count = 0;
        while (rs.next()) {
            if (count % 100 == 0) {
                System.out.println(category + ": " + count);
            }

            Map<String, Object> waypoint = new HashMap<>();
            waypoints.add(waypoint);
            writeResultSet(rs, waypoint);
//            System.out.println("CacheCode: " + rs.getString("Code"));
            writeLogs(connection, rs.getString("Code"), waypoint);
            count++;
        }
        rs.close();
        long duration = System.currentTimeMillis() - startTime;
        System.out.println("Read into Memory: " + category + ". Aus die Maus!");
        System.out.println("Zeitbedarf: " + duration + "ms");
        NumberFormat nf = new DecimalFormat("0.0");
        System.out.println("pro Cache: " + nf.format (duration / (double)count) + "ms");
//        showMemory();
        return waypoints;
    }


    private static void exportToXML(final String category) throws Exception {
        Class.forName("org.sqlite.JDBC");
        Connection connection = DriverManager.getConnection("jdbc:sqlite:" + "/Users/mbu/ExtDisk/Geo/GSAK8/data/Default/sqlite.db3");
        long startTime = System.currentTimeMillis();
        final Statement statement = connection.createStatement();
        final String sql = "select *, group_concat(at.aId || '-' || at.aInc) as Attributes " +
                " from Caches ca " +
                " join Custom cu on ca.code = cu.cCode " +
                " join CacheMemo cm on ca.code=cm.Code " +
                " left join Attributes at on ca.Code = at.aCode " +
                " where 1=1 " +
//                " and round(ca.latitude, 6) >= " + "46" +
//                " and round(ca.latitude, 6) < " + "48.6" +
//                " and round(ca.longitude, 6) >= " + "6" +
//                " and round(ca.longitude,6) < " + "8.6" +
                " group by ca.Code " +
                " limit 100000";
        final ResultSet rs = statement.executeQuery(sql);

        XMLOutputFactory xof = XMLOutputFactory.newInstance();
//        XMLStreamWriter xtw = xof.createXMLStreamWriter(new FileWriter("gsak.xml"));
        XMLStreamWriter xtw = xof.createXMLStreamWriter(new OutputStreamWriter(new FileOutputStream(category + ".xml"), StandardCharsets.UTF_8));
        xtw.writeStartDocument("utf-8", "1.0");
        xtw.writeComment("Demo");

        int count = 0;
        xtw.writeStartElement("caches");
        while (rs.next()) {
            if (count % 100 == 0) {
                System.out.println(category + ": " + count);
            }
            xtw.writeStartElement("wpt");
            writeResultSet(rs, xtw);
            writeLogs(connection, rs.getString("Code"), xtw);
            xtw.writeEndElement();
            xtw.writeCharacters("\n");
            count++;
        }
        xtw.writeEndElement();
        xtw.writeEndDocument();
        xtw.flush();
        xtw.close();
        rs.close();
        long duration = System.currentTimeMillis() - startTime;
        System.out.println("Export: " + category + ". Aus die Maus!");
        System.out.println("Zeitbedarf: " + duration + "ms");
        NumberFormat nf = new DecimalFormat("0.0");
        System.out.println("pro Cache: " + nf.format (duration / (double)count) + "ms");
    }

    private static void transformToGpx(final String category) throws Exception {
showMemory();
        long startTime = System.currentTimeMillis();

        String[] arglist = {"-o:" + category + ".gpx", category + ".xml", "transform.xslt"};
        Transform.main(arglist);

        long duration = System.currentTimeMillis() - startTime;
showMemory();
        System.out.println("Transform: Aus die Maus!");
        System.out.println("Zeitbedarf: " + duration + "ms");
    }

    private static void showMemory() {
     long freeMemory = Runtime.getRuntime().freeMemory()/MegaBytes;
        long totalMemory = Runtime.getRuntime().totalMemory()/MegaBytes;
        long maxMemory = Runtime.getRuntime().maxMemory()/MegaBytes;

        System.out.println("JVM freeMemory: " + freeMemory);
        System.out.println("JVM totalMemory also equals to initial heap size of JVM : "
                                        + totalMemory);
        System.out.println("JVM maxMemory also equals to maximum heap size of JVM: "
                                         + maxMemory);

        List<MemoryPoolMXBean> pools = ManagementFactory.getMemoryPoolMXBeans();
        long total = 0;
        for (MemoryPoolMXBean memoryPoolMXBean : pools)
        {
            if (memoryPoolMXBean.getType() == MemoryType.HEAP)
            {
                long peakUsed = memoryPoolMXBean.getPeakUsage().getUsed();
                System.out.println("Peak used for: " + memoryPoolMXBean.getName() + " is: " + peakUsed / MegaBytes);
                total = total + peakUsed;
            }
        }

        System.out.println("Total heap peak used: " + total / MegaBytes);
    }

    private static void writeLogs(Connection connection, String code, XMLStreamWriter xtw) throws Exception {
        final Statement statement = connection.createStatement();
/*        final String sql = "select * " +
                " from Logs lo " +
                " join LogMemo lm on lo.lLogId=lm.lLogId and lo.lParent=lm.lParent " +
                " where lo.lLogId in ( " +
                "  select lLogId " +
                "  from Logs " +
                "  where lParent = '" + code + "' " +
                "  order by lDate desc " +
                "  limit 5 " +
                ") " +
                "order by lo.lParent, lo.lDate desc;";*/
        final String sql = "select * " +
                " from Logs lo " +
                " join LogMemo lm on lo.lLogId=lm.lLogId and lo.lParent=lm.lParent " +
                " where lo.lParent = '" + code + "' " +
                "  order by lo.lDate desc " +
                "  limit 10; ";
        final ResultSet rs = statement.executeQuery(sql);
        xtw.writeStartElement("logs");
        while (rs.next()) {
            xtw.writeStartElement("log");
            writeResultSet(rs, xtw);
            xtw.writeEndElement();
        }
        xtw.writeEndElement();
        rs.close();
    }

    private static void writeLogs(Connection connection, String code, Map<String, Object> waypoint) throws Exception {
        final Statement statement = connection.createStatement();
        final String sql = "select lo.lLogId, lType, lBy, lDate, lownerid, substr(lText, 1, 2000) as lText " +
                " from Logs lo " +
                " join LogMemo lm on lo.lLogId=lm.lLogId and lo.lParent=lm.lParent " +
                " where lo.lParent = '" + code + "' " +
                " and length(lText) > 20 " +
                " order by lo.lDate desc " +
                " limit 10; ";
        final ResultSet rs = statement.executeQuery(sql);
        List<Map<String, Object>> logs = new ArrayList<>();
        while (rs.next()) {
            Map<String, Object> log = new HashMap<>();
            logs.add(log);
            writeResultSet(rs, log);
        }
        waypoint.put("logs", logs);
        rs.close();
    }

    private static void writeResultSet(ResultSet rs, XMLStreamWriter xtw) throws SQLException, XMLStreamException {
        final int columnCount = rs.getMetaData().getColumnCount();
        for (int col = 1; col <= columnCount; col++) {
            final String columnName = rs.getMetaData().getColumnName(col);
            final String columnValue = rs.getString(col);
            if (columnValue != null && columnValue.length() > 0) {
                xtw.writeStartElement(columnName);
                xtw.writeCharacters(columnValue.replaceAll("[\u0000-\u0009\u000e-\u001f\u007f]", ""));
                xtw.writeEndElement();
            }
        }
    }

    private static void writeResultSet(ResultSet rs, Map<String, Object> waypoint) throws SQLException, XMLStreamException {
        final int columnCount = rs.getMetaData().getColumnCount();
        for (int col = 1; col <= columnCount; col++) {
            final String columnName = rs.getMetaData().getColumnName(col);
            final int columnType = rs.getMetaData().getColumnType(col);
            switch (columnType) {
                case Types.INTEGER:
                    waypoint.put(columnName, rs.getInt(col));
                    break;

                case Types.REAL:
                    waypoint.put(columnName, rs.getDouble(col));
                    break;

                default:
                    final String columnValue = rs.getString(col);
                    if (columnValue != null && columnValue.length() > 0) {
                        waypoint.put(columnName, columnValue.replaceAll("[\u0000-\u0009\u000e-\u001f\u007f]", ""));
                    } else {
                        waypoint.put(columnName, "");
                    }
                    break;
            }

        }
    }
}
