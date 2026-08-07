<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:local="http://dse-static.foo.bar" version="2.0" exclude-result-prefixes="xsl tei xs local">
    <xsl:output encoding="UTF-8" media-type="text/html" method="html" version="5.0" indent="yes" omit-xml-declaration="yes" />

    <xsl:import href="./partials/html_head.xsl" />
    <xsl:import href="./partials/html_navbar.xsl" />
    <xsl:import href="./partials/html_footer.xsl" />
    <xsl:import href="./partials/one_time_alert.xsl" />

    <xsl:template match="/">
        <xsl:variable name="doc_title">
            <xsl:value-of select='"Fassungsvergleich"' />
        </xsl:variable>
        <html lang="{$default_lang}">
            <head>
                <xsl:call-template name="html_head">
                    <xsl:with-param name="html_title" select="$doc_title"></xsl:with-param>
                </xsl:call-template>
                <link rel="stylesheet" href="css/synopticTextViewer.css"/>
                <link rel="stylesheet" href="css/column_viewer.css"/>
                <script type="module" src="js/synopticTextViewer/columnViewer.js"/>
            </head>
            <body>
                <xsl:call-template name="nav_bar" />
                <main>
                    <div class="synTexView_controls_wrapper">
                        <button class="synTexView_controls_toggle">Menu</button>
                        <div class="synTexView_controls" id="synTexView-controls-container" role="menu" aria-label="Synoptic viewer options">
                            <div id="column-adder"></div>
                            <div id="empty-line-toggler"></div>
                            <div id="global-linenr-toggler"></div>
                            <div id="local-linenr-toggler"></div>
                            <div id="generate-citation-url"></div>
                        </div>
                    </div>
                    <div id="synTexView-witness-container"></div>
                </main>
                <xsl:call-template name="html_footer" />
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>