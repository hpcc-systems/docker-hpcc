<?xml version="1.0" encoding="UTF-8"?>
<!--
################################################################################
#    HPCC SYSTEMS software Copyright (C) 2018 HPCC Systems®.
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
        <xsl:call-template name="printVariable">
            <xsl:with-param name="var" select="'SPARK_EXECUTOR_CORES'"/>
            <xsl:with-param name="val" select="@SPARK_EXECUTOR_CORES"/>
        </xsl:call-template>
        <xsl:call-template name="printVariable">
            <xsl:with-param name="var" select="'SPARK_EXECUTOR_MEMORY'"/>
            <xsl:with-param name="val" select="@SPARK_EXECUTOR_MEMORY"/>
        </xsl:call-template>
        <xsl:call-template name="printVariable">
            <xsl:with-param name="var" select="'SPARK_MASTER_HOST'"/>
            <xsl:with-param name="val" select="Instance/@netAddress[1]"/>
        </xsl:call-template>
        <xsl:call-template name="printVariable">
            <xsl:with-param name="var" select="'SPARK_MASTER_WEBUI_PORT'"/>
            <xsl:with-param name="val" select="@SPARK_MASTER_WEBUI_PORT"/>
        </xsl:call-template>
        <xsl:call-template name="printVariable">
            <xsl:with-param name="var" select="'SPARK_MASTER_PORT'"/>
            <xsl:with-param name="val" select="@SPARK_MASTER_PORT"/>
        </xsl:call-template>
        <xsl:call-template name="printVariable">
            <xsl:with-param name="var" select="'SPARK_WORKER_CORES'"/>
            <xsl:with-param name="val" select="@SPARK_WORKER_CORES"/>
        </xsl:call-template>
        <xsl:call-template name="printVariable">
            <xsl:with-param name="var" select="'SPARK_WORKER_MEMORY'"/>
            <xsl:with-param name="val" select="@SPARK_WORKER_MEMORY"/>
        </xsl:call-template>
        <xsl:call-template name="printVariable">
            <xsl:with-param name="var" select="'SPARK_WORKER_PORT'"/>
            <xsl:with-param name="val" select="@SPARK_WORKER_PORT"/>
        </xsl:call-template>
        <xsl:call-template name="printVariable">
            <xsl:with-param name="var" select="'NODEGROUP'"/>
            <xsl:with-param name="val" select="@ThorClusterName"/>
        </xsl:call-template>
        <xsl:text>export DALISERVER=</xsl:text>
        <xsl:call-template name="getThorNodeDali">
            <xsl:with-param name="thorNode" select="@ThorClusterName"/>
        </xsl:call-template>
        <xsl:text>&#xa;</xsl:text>
        <xsl:text>export SPARK_LOG_DIR=/var/log/HPCCSystems/</xsl:text><xsl:value-of select="@name"/><xsl:text>&#xa;</xsl:text>
        <xsl:text>export SPARK_PID_DIR=/var/run/HPCCSystems&#xa;</xsl:text>
        <xsl:text>export SPARK_CONF_DIR=/var/lib/HPCCSystems/</xsl:text><xsl:value-of select="@name"/><xsl:text>&#xa;</xsl:text>
        <xsl:text>export SPARK_WORKER_DIR=/var/lib/HPCCSystems/</xsl:text><xsl:value-of select="@name"/><xsl:text>&#xa;</xsl:text>
    </xsl:template>

    <!-- printVariable -->
    <xsl:template name="printVariable">
        <xsl:param name="var"/>
        <xsl:param name="val"/>
        <xsl:if test="$val">
            <xsl:text>export </xsl:text><xsl:value-of select="$var"/><xsl:text>=</xsl:text><xsl:value-of select="$val"/><xsl:text>&#xa;</xsl:text>
        </xsl:if>
    </xsl:template>
    <!-- printVariable -->

    <!-- getThorNodeDali -->
    <xsl:template name="getThorNodeDali">
        <xsl:param name="thorNode"/>
        <xsl:for-each select="/Environment/Software/ThorCluster[@name=$thorNode]">
            <xsl:call-template name="getDaliServers">
                <xsl:with-param name="daliServer" select="@daliServers"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    <!-- getThorNodeDali -->

    <!-- getDaliServers -->
    <xsl:template name="getDaliServers">
        <xsl:param name="daliServer"/>
        <xsl:for-each select="/Environment/Software/DaliServerProcess[@name=$daliServer]/Instance">
            <xsl:call-template name="getNetAddress">
                <xsl:with-param name="computer" select="@computer"/>
            </xsl:call-template>
            <xsl:if test="string(@port) != ''">:<xsl:value-of select="@port"/></xsl:if>
            <xsl:if test="position() != last()">, </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <!-- getDaliServers -->

    <!-- getNetAddress -->
    <xsl:template name="getNetAddress">
        <xsl:param name="computer"/>
        <xsl:value-of select="/Environment/Hardware/Computer[@name=$computer]/@netAddress"/>
    </xsl:template>
    <!-- getNetAddress -->

</xsl:stylesheet>
