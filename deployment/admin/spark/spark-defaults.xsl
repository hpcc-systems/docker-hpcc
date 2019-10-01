<?xml version="1.0" encoding="UTF-8"?>
<!--
################################################################################
#    HPCC SYSTEMS software Copyright (C) 2017 HPCC Systems®.
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
################################################################################
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xml:space="default">
    <xsl:output method="text" indent="no" omit-xml-declaration="yes"/>
    <xsl:strip-space elements="*"/>
    <xsl:param name="process" select="'sparkthor'"/>
    <xsl:param name="isLinuxInstance" select="0" />
    <xsl:param name="outputFilePath" />

    <xsl:template match="/">
        <xsl:apply-templates select="/Environment/Software/SparkThorProcess[@name=$process]"/>
    </xsl:template>

    <xsl:template match="SparkThorProcess">
spark.driver.extraClassPath /opt/HPCCSystems/jars/spark/*
spark.executor.extraClassPath /opt/HPCCSystems/jars/spark/*
    </xsl:template>

</xsl:stylesheet>
