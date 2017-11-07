<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:xdt="http://www.w3.org/2005/xpath-datatypes"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.w3.org/1999/XSL/Format ">

    <xsl:output method="xml" indent="yes"/>
	<xsl:strip-space elements="*"/>

    <xsl:template match="caches">
        <xsl:element name="gpx" namespace="http://www.topografix.com/GPX/1/1">
            <xsl:namespace name="gpxx" select="'http://www.garmin.com/xmlschemas/GpxExtensions/v3'"/>
            <xsl:namespace name="xsi" select="'http://www.w3.org/2001/XMLSchema-instance'"/>
			<xsl:attribute name="creator" select="'gsak2gpx by Markus Bubendorf'" />
			<xsl:attribute name="version" select="'1.1'" />
			<xsl:attribute name="xsi:schemaLocation" select="'http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd http://www.garmin.com/xmlschemas/GpxExtensions/v3 http://www8.garmin.com/xmlschemas/GpxExtensions/v3/GpxExtensionsv3.xsd'" />
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="wpt">
        <xsl:element name="wpt">
            <xsl:attribute name="lon">
                <xsl:value-of select="Longitude"/>
            </xsl:attribute>
            <xsl:attribute name="lat">
                <xsl:value-of select="Latitude"/>
            </xsl:attribute>
            <xsl:element name="ele">
                <xsl:value-of select="Elevation"/>
            </xsl:element>
            <xsl:element name="name">
                <xsl:value-of select="Code"/>
            </xsl:element>
            <xsl:element name="desc">
                <xsl:value-of select="SmartName"/>
            </xsl:element>
            <xsl:element name="urlname">
                <xsl:value-of select="Name"/> by <xsl:value-of select="OwnerName"/>
            </xsl:element>
            <xsl:element name="sym">Geocache</xsl:element>
            <xsl:element name="Type">Geocache|<xsl:choose>
                    <xsl:when test = "CacheType = 'T'">Traditional Cache</xsl:when>
                    <xsl:when test = "CacheType = 'M'">Multi Cache</xsl:when>
                    <xsl:when test = "CacheType = 'U'">Mystery Cache</xsl:when>
                </xsl:choose>
            </xsl:element>
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>
