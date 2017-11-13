package ch.bubendorf.ggzgen;

import org.apache.commons.lang.StringEscapeUtils;

public class CacheIndex {
    private String code;
    private String name;
    private String type;
    private double lat;
    private double lon;
    private int file_pos;
    private int file_len;
    private double awesomeness;
    private double difficulty;
    private int size;
    private double terrain;

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public double getLat() {
        return lat;
    }

    public void setLat(double lat) {
        this.lat = lat;
    }

    public double getLon() {
        return lon;
    }

    public void setLon(double lon) {
        this.lon = lon;
    }

    public int getFile_pos() {
        return file_pos;
    }

    public void setFile_pos(int file_pos) {
        this.file_pos = file_pos;
    }

    public int getFile_len() {
        return file_len;
    }

    public void setFile_len(int file_len) {
        this.file_len = file_len;
    }

    public double getAwesomeness() {
        return awesomeness;
    }

    public void setAwesomeness(double awesomeness) {
        this.awesomeness = awesomeness;
    }

    public double getDifficulty() {
        return difficulty;
    }

    public void setDifficulty(double difficulty) {
        this.difficulty = difficulty;
    }

    public int getSize() {
        return size;
    }

    public void setSize(int size) {
        this.size = size;
    }

    public double getTerrain() {
        return terrain;
    }

    public void setTerrain(double terrain) {
        this.terrain = terrain;
    }

    public String toXML() {
        return "<gch>\n" +
                "<code>" + code + "</code>\n" +
                "<name>" + StringEscapeUtils.escapeXml(name) + "</name>\n" +
                "<type>" + type + "</type>\n" +
                "<lat>" + lat + "</lat>\n" +
                "<lon>" + lon + "</lon>\n" +
                "<file_pos>" + file_pos + "</file_pos>\n" +
                "<file_len>" + file_len + "</file_len>\n" +
                "<ratings>\n" +
                "<awesomeness>" + awesomeness + "</awesomeness>\n" +
                "<difficulty>" + difficulty + "</difficulty>\n" +
                "<size>" + size + "</size>\n" +
                "<terrain>" + terrain + "</terrain>\n" +
                "</ratings>\n" +
                "</gch>\n";
    }
}
