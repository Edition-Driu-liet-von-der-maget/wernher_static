<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0" exclude-result-prefixes="xsl tei xs">
    <xsl:output encoding="UTF-8" media-type="text/html" method="html" version="5.0" indent="yes" omit-xml-declaration="yes"/>
    
    <xsl:import href="partials/shared.xsl"/>
    <xsl:import href="partials/html_navbar.xsl"/>
    <xsl:import href="partials/html_head.xsl"/>
    <xsl:import href="partials/html_footer.xsl"/>
    <xsl:import href="partials/blockquote.xsl"/>
    <xsl:import href="partials/zotero.xsl"/>
    <xsl:import href="partials/edition_metadata.xsl"/>
    <!-- TEI-specific inline and structural rendering rules (verses, choices, ligatures, initials, etc.) -->
    <xsl:import href="edition_specifics.xsl"/>

    <xsl:variable name="prev">
        <xsl:value-of select="replace(tokenize(data(tei:TEI/@prev), '/')[last()], '.xml', '.html')"/>
    </xsl:variable>
    <xsl:variable name="next">
        <xsl:value-of select="replace(tokenize(data(tei:TEI/@next), '/')[last()], '.xml', '.html')"/>
    </xsl:variable>
    <xsl:variable name="teiSource">
        <xsl:choose>
            <xsl:when test="normalize-space(string(/tei:TEI/@xml:id))">
                <xsl:value-of select="string(/tei:TEI/@xml:id)"/>
            </xsl:when>
            <xsl:when test="normalize-space(string(.//tei:sourceDesc/tei:msDesc[1]/@xml:id))">
                <xsl:value-of select="concat(string(.//tei:sourceDesc/tei:msDesc[1]/@xml:id), '.xml')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="tokenize(base-uri(/), '/')[last()]"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="link">
        <xsl:value-of select="replace($teiSource, '.xml', '.html')"/>
    </xsl:variable>
    <xsl:variable name="doc_title">
        <xsl:value-of select=".//tei:titleStmt/tei:title[1]/text()"/>
    </xsl:variable>


    <xsl:template match="/">
        <html class="h-100" lang="{$default_lang}">
            <head>
                <xsl:call-template name="html_head">
                    <xsl:with-param name="html_title" select="$doc_title"></xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="zoterMetaTags">
                    <xsl:with-param name="pageId" select="$link"></xsl:with-param>
                    <xsl:with-param name="zoteroTitle" select="$doc_title"></xsl:with-param>
                </xsl:call-template>
                <meta name="citation_author" content="Foo, Bar"/>
                <meta name="citation_author" content="Bar, Foo"/> 
                <link rel="stylesheet" href="css/edition.css"/>
            </head>
            <body class="d-flex flex-column h-100">
                <xsl:call-template name="nav_bar"/>
                <main class="flex-shrink-0 flex-grow-1">
                    <nav aria-label="breadcrumb" class="ps-5 p-3 edition-breadcrumb-nav">
                        <ol class="breadcrumb">
                            <li class="breadcrumb-item">
                                <a href="index.html">
                                    <xsl:value-of select="$project_short_title"/>
                                </a>
                            </li>
                            <li class="breadcrumb-item">
                                <a href="toc.html">
                                    <xsl:value-of select="'Inhaltsverzeichnis'"/>
                                </a>
                            </li>
                            <li class="breadcrumb-item active" aria-current="page">
                                <xsl:value-of select="$doc_title"/>
                            </li>
                        </ol>
                    </nav>
                    <div class="container">
                        <div class="row">
                            <div class="col-md-2 col-lg-2 col-sm-12 text-start">
                                <xsl:if test="ends-with($prev,'.html')">
                                    <a>
                                        <xsl:attribute name="href">
                                            <xsl:value-of select="$prev"/>
                                        </xsl:attribute>
                                        <i class="fs-2 bi bi-chevron-left" title="Zurück zum vorigen Dokument" visually-hidden="true">
                                            <span class="visually-hidden">Zurück zum vorigen Dokument</span>
                                        </i>
                                    </a>
                                </xsl:if>
                            </div>
                            <div class="col-md-8 col-lg-8 col-sm-12 text-center">
                                <h1>
                                    <xsl:value-of select="$doc_title"/>
                                </h1>
                                <div>
                                    <a href="{$teiSource}">
                                        <i class="bi bi-download fs-2" title="Zum TEI/XML Dokument" visually-hidden="true">
                                            <span class="visually-hidden">Zum TEI/XML Dokument</span>
                                        </i>
                                    </a>
                                </div>
                            </div>
                            <div class="col-md-2 col-lg-2 col-sm-12 text-start">
                                <xsl:if test="ends-with($next, '.html')">
                                    <a>
                                        <xsl:attribute name="href">
                                            <xsl:value-of select="$next"/>
                                        </xsl:attribute>
                                        <i class="fs-2 bi bi-chevron-right" title="Weiter zum nächsten Dokument" visually-hidden="true">
                                            <span class="visually-hidden">Weiter zum nächsten Dokument</span>
                                        </i>
                                    </a>
                                </xsl:if>
                            </div>
                        </div>
                        <div class="edition-toolbar" role="toolbar" aria-label="Ansicht">
                            <button type="button" id="toggle-global-vers-numbers" class="btn edition-toolbar-btn" aria-pressed="true" title="Globale Versnummern ein- bzw. ausblenden">
                                <i aria-hidden="true"></i><span class="edition-toolbar-label">Globale Versnummern</span>
                            </button>
                            <button type="button" id="toggle-local-vers-numbers" class="btn edition-toolbar-btn" aria-pressed="false" title="Lokale Versnummern ein- bzw. ausblenden">
                                <i aria-hidden="true"></i><span class="edition-toolbar-label">Lokale Versnummern</span>
                            </button>
                            <xsl:if test="exists(//tei:facsimile/tei:surface)">
                                <button type="button" id="toggle-facs-sync" class="btn edition-toolbar-btn" aria-pressed="true" title="Text/Bild synchronisieren ein- bzw. ausschalten">
                                    <i class="bi bi-link-45deg" aria-hidden="true"></i><span class="edition-toolbar-label">Text/Bild synchronisieren</span>
                                </button>
                            </xsl:if>
                            <button type="button" id="scroll-to-top" class="btn edition-toolbar-btn edition-toolbar-btn--push-end" title="Nach oben scrollen">
                                <span class="edition-toolbar-arrow-up" aria-hidden="true"></span><span class="edition-toolbar-label">Nach oben</span>
                            </button>
                        </div>
                        <div class="edition-layout">
                            <xsl:if test="exists(//tei:facsimile/tei:surface)">
                                <xsl:attribute name="class">edition-layout edition-layout--facs</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="exists(//tei:facsimile/tei:surface)">
                                <aside class="edition-facs-col">
                                    <div class="edition-facs-sticky">
                                        <div id="edition-facs-viewer" class="edition-facs-viewer" role="img" aria-label="Faksimile der Handschriftenseite"></div>
                                        <div class="edition-facs-caption">
                                            <span id="edition-facs-label" class="edition-facs-label"></span>
                                            <div class="edition-facs-nav" role="group" aria-label="Seitennavigation">
                                                <button type="button" id="edition-facs-prev" class="btn edition-toolbar-btn edition-facs-btn" aria-label="Vorherige Seite" title="Vorherige Seite">
                                                    <i class="bi bi-chevron-left" aria-hidden="true"></i>
                                                </button>
                                                <button type="button" id="edition-facs-next" class="btn edition-toolbar-btn edition-facs-btn" aria-label="Nächste Seite" title="Nächste Seite">
                                                    <i class="bi bi-chevron-right" aria-hidden="true"></i>
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                </aside>
                            </xsl:if>
                            <div class="edition-content-col">
                                <xsl:call-template name="render_edition_metadata"/>
                                <xsl:apply-templates select=".//tei:body"></xsl:apply-templates>
                        <p class="edition-footnotes-wrapper">
                            <xsl:for-each select=".//tei:note[not(./tei:p)]">
                                <div class="footnotes">
                                    <xsl:element name="a">
                                        <xsl:attribute name="name">
                                            <xsl:text>fn</xsl:text>
                                            <xsl:number level="any" format="1" count="tei:note"/>
                                        </xsl:attribute>
                                        <a>
                                            <xsl:attribute name="href">
                                                <xsl:text>#fna_</xsl:text>
                                                <xsl:number level="any" format="1" count="tei:note"/>
                                            </xsl:attribute>
                                            <span class="edition-footnote-ref-number">
                                                <xsl:number level="any" format="1" count="tei:note"/>
                                            </span>
                                        </a>
                                    </xsl:element>
                                    <xsl:apply-templates/>
                                </div>
                            </xsl:for-each>
                        </p>

                        <div class="text-center p-4">
                            <xsl:call-template name="blockquote">
                                <xsl:with-param name="pageId" select="$link"/>
                            </xsl:call-template>
                        </div>
                            </div>
                        </div>

                    </div>
                    <xsl:for-each select="//tei:back">
                        <div class="tei-back">
                            <xsl:apply-templates/>
                        </div>
                    </xsl:for-each>
                </main>
                <xsl:call-template name="html_footer"/>
                <script src="vendor/openseadragon-bin-4.1.1/openseadragon.min.js"/>
                <script src="js/facs-viewer.js"></script>
                <script src="js/tei-line-dblclick.js"></script>
                <script src="js/toggle-vers-numbers.js"></script>
                <script src="js/scroll-to-top.js"></script>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
