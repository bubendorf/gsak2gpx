package ch.bubendorf.gsak2gpx;

import freemarker.template.*;

import java.sql.ResultSet;

/**
 * Makes using a ResultSet in FreeMarker a little easier.
 * <p>
 * Uses TemplateSequenceModel to get access to each ResultSet row then uses
 * TemplateHashModel to get access to each column.
 * <p>
 * NOTE: All columns are returned using rs.getString(). This may or may not work
 * for you.
 * <p>
 * Example usage
 * <p>
 * in your Java source:
 * ResultSet rs = conn.createStatement().executeQuery("select ...");
 * TemplateSequenceModel rows = new ResultSetModel(rs);
 * root.put("rows",rows);
 * <p>
 * in your .ftl:
 * <#list rows as row>
 * <tr><td>${row["column_1"]}</td><td>${row["column_2"]}</td><td>${row["column_n"]}</td></tr>
 * </#list>
 * <p>
 * <p>
 * This is LGPL'd:
 * <p>
 * ResultSetModel, a simple FreeMarker utility Copyright (C) 2008 Chad Armstrong
 * This library is free software; you can redistribute it and/or modify it under the terms of
 * the GNU Lesser General Public License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * <p>
 * This library is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU Lesser General Public License for more details.
 * <p>
 * You should have received a copy of the GNU Lesser General Public License along with this
 * library; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA 02111-1307 USA
 *
 * @author Chad Armstrong (chasd00@gmail.com)
 */

public class ResultSetSequenceModel implements TemplateSequenceModel {

    private ResultSet rs = null;

    public ResultSetSequenceModel(ResultSet rs) {
        this.rs = rs;
    }

    public TemplateModel get(int i) throws TemplateModelException {
        try {
            rs.next();
        } catch (Exception e) {
            throw new TemplateModelException(e.toString());
        }
        TemplateModel model = new Row(rs);
        return model;
    }

    public int size() throws TemplateModelException {
        int size = 0;
        try {
            rs.last();
            size = rs.getRow();
            rs.beforeFirst();
        } catch (Exception e) {
            throw new TemplateModelException(e.toString());
        }
        return size;
    }


    class Row implements TemplateHashModel {

        private ResultSet rs = null;

        public Row(ResultSet rs) {
            this.rs = rs;
        }

        public TemplateModel get(String s) throws TemplateModelException {
            TemplateModel model = null;
            try {
                model = new SimpleScalar(rs.getString(s));
            } catch (Exception e) {
                e.printStackTrace();
            }
            return model;
        }

        public boolean isEmpty() throws TemplateModelException {
            boolean isEmpty = false;
            if (rs == null) {
                isEmpty = true;
            }
            return isEmpty;
        }

    }
}
