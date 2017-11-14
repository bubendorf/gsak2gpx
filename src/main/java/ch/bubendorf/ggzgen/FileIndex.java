package ch.bubendorf.ggzgen;

import java.util.ArrayList;
import java.util.List;

@SuppressWarnings({"WeakerAccess", "unused"})
public class FileIndex {
    private String name;
    private String crc;
    private List<CacheIndex> gch = new ArrayList<>();

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getCrc() {
        return crc;
    }

    public void setCrc(String crc) {
        this.crc = crc;
    }

    public void addCacheIndex(CacheIndex cacheIndex) {
        gch.add(cacheIndex);
    }

    public int getCacheIndexSize() {
        return gch.size();
    }

    public String toXML() {
        StringBuilder sb = new StringBuilder();
        sb.append("<file>\n");
        sb.append("<name>").append(name).append("</name>\n");
        sb.append("<crc>").append(crc).append("</crc>\n");
        for (CacheIndex cacheIndex : gch) {
            sb.append(cacheIndex.toXML());
        }

        sb.append("</file>\n");
        return sb.toString();
    }
}
