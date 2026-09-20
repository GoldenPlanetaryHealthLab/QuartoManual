<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:svg="http://www.w3.org/2000/svg"
  exclude-result-prefixes="svg">

  <xsl:output method="xml" encoding="UTF-8"/>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- Mermaid centers native SVG labels. Move code labels to a 30px inset. -->
  <xsl:template match="svg:g[contains(concat(' ', normalize-space(@class), ' '), ' node ') and contains(concat(' ', normalize-space(@class), ' '), ' code ')]/svg:g[@class='label']">
    <xsl:copy>
      <xsl:apply-templates select="@*[name() != 'transform']"/>
      <xsl:attribute name="transform">
        <xsl:text>translate(</xsl:text>
        <xsl:value-of select="number(../svg:rect[@class='basic label-container']/@x) + 30"/>
        <xsl:text>, </xsl:text>
        <xsl:value-of select="substring-before(substring-after(@transform, ', '), ')')"/>
        <xsl:text>)</xsl:text>
      </xsl:attribute>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="svg:g[contains(concat(' ', normalize-space(@class), ' '), ' node ') and contains(concat(' ', normalize-space(@class), ' '), ' code ')]//svg:text">
    <xsl:copy>
      <xsl:apply-templates select="@*[name() != 'style']"/>
      <xsl:attribute name="style">
        <xsl:value-of select="@style"/>
        <xsl:text>;text-anchor:start!important</xsl:text>
      </xsl:attribute>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- Leading spaces in Mermaid's nested tspans collapse in Typst. -->
  <xsl:template match="svg:tspan[starts-with(text(), ' ')]">
    <xsl:copy>
      <xsl:apply-templates select="@*[name() != 'dx']"/>
      <xsl:attribute name="dx">0.35em</xsl:attribute>
      <xsl:value-of select="substring(text(), 2)"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
