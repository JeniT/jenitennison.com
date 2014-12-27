<?xml-stylesheet type="text/xsl" href=""?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:my="http://www.example.com/datatypes"
                exclude-result-prefixes="xs xsi"
                version="2.0">

<xsl:import href="test-datatypes.xsl" />

<xsl:output method="xml" indent="yes" />

<xsl:template match="/">
  Illegal date:
  <xsl:sequence select="my:UKDate('29/02/2003')" />
</xsl:template>

</xsl:stylesheet>